// src/contexts/SettingsContext.js
import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { settingsAPI } from '../services/api';
import { Spin } from 'antd';

const SettingsContext = createContext();

export const useSettings = () => {
  const context = useContext(SettingsContext);
  if (!context) {
    throw new Error('useSettings must be used within a SettingsProvider');
  }
  return context;
};

export const SettingsProvider = ({ children }) => {
  const [settings, setSettings] = useState(null);
  const [loading, setLoading] = useState(true);

  // Fetch settings when the app loads
  // Fetch settings function
  const fetchSettings = useCallback(async () => {
    setLoading(true);
    try {
      const response = await settingsAPI.get();
      setSettings(response.data);
    } catch (error) {
      console.error('Failed to load app settings:', error);
      // Set default settings if fetch fails
      setSettings({
        allowNewEnrollments: true,
        allowNewDrugs: true,
        allowNewDepartments: true,
        allowNewPatients: true,
      });
    } finally {
      setLoading(false);
    }
  }, []);

  // Fetch settings when the app loads
  useEffect(() => {
    fetchSettings();
  }, [fetchSettings]);

  // Function to update settings both in state and on the backend
  const updateSettings = useCallback(async (newSetting) => {
    if (!settings) return;

    // Optimistic update: update state immediately for fast UI
    const oldSettings = settings;
    const updatedSettings = { ...settings, ...newSetting };
    setSettings(updatedSettings);

    try {
      // Send the update to the API
      await settingsAPI.update(newSetting);
    } catch (error) {
      // If API fails, roll back the change and show error
      console.error('Failed to update setting:', error);
      setSettings(oldSettings); // Rollback
      throw error; // Re-throw error for the component to catch
    }
  }, [settings]);

  const value = {
    settings,
    loading,
    updateSettings,
    fetchSettings, // Expose fetchSettings
  };

  // Show a full-page loader while settings are loading
  if (loading) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh' }}>
        <Spin size="large" />
      </div>
    );
  }

  return (
    <SettingsContext.Provider value={value}>
      {children}
    </SettingsContext.Provider>
  );
};