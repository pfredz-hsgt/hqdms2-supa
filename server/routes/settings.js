// server/routes/settings.js
const express = require('express');
const pool = require('../config/database');
const router = express.Router();
// const { adminAuthMiddleware } = require('../middleware/auth'); // TODO: Add your admin auth middleware

/**
 * GET /api/settings
 * Fetches the current application settings.
 */
router.get('/', async (req, res) => {
  try {
    // Select the one and only settings row
    const result = await pool.query('SELECT * FROM app_settings WHERE id = 1');
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Application settings not found.' });
    }
    
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

/**
 * PUT /api/settings
 * Updates application settings.
 * This route should be protected and only accessible by admins.
 */
// Don't forget to add your admin authentication middleware here!
router.put('/', /* adminAuthMiddleware, */ async (req, res) => {
  // A whitelist of keys that are allowed to be updated
  const validKeys = [
    'allowNewEnrollments',
    'allowNewDrugs',
    'allowNewDepartments',
    'allowNewPatients'
  ];

  const updates = req.body;
  const fields = [];
  const values = [];
  let paramIndex = 1;

  // Build the SQL query dynamically and securely based on the whitelist
  for (const key of validKeys) {
    if (updates[key] !== undefined) {
      // Note the double-quotes to match the case-sensitive column names
      fields.push(`"${key}" = $${paramIndex}`);
      values.push(updates[key]);
      paramIndex++;
    }
  }

  // If no valid fields were sent, return an error
  if (fields.length === 0) {
    return res.status(400).json({ error: 'No valid settings fields provided.' });
  }

  try {
    const query = `
      UPDATE app_settings
      SET ${fields.join(', ')}
      WHERE id = 1
      RETURNING *
    `;
    
    const result = await pool.query(query, values);
    res.json(result.rows[0]); // Send back the updated settings object
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;