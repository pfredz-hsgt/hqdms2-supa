import axios from 'axios';

// Function to get the correct API base URL
const getApiBaseUrl = () => {
  // 1. Check for a specific production build environment
  if (process.env.NODE_ENV === 'production') {
    // In production, all API requests are relative to the same host.
    // Apache will handle the proxy.
    return '/api';
  }

  // 2. Check for a user-defined dev URL
  if (process.env.REACT_APP_API_URL) {
    return process.env.REACT_APP_API_URL;
  }
  
  // 3. Fallback for local development
  return 'http://localhost:3003/api';
};

const API_BASE_URL = getApiBaseUrl();

// Log the API base URL for debugging
console.log('API Base URL:', API_BASE_URL);
console.log('Current hostname:', window.location.hostname);
console.log('Current port:', window.location.port);

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
api.interceptors.request.use(
  (config) => {
    // Add auth token to requests
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    // Always log the error details for debugging
    console.error('API Error:', error.response?.status, error.response?.data || error.message); 

    // Handle 401 unauthorized errors, BUT NOT ON THE LOGIN PAGE ITSELF
    // Check window.location.hash because you are using HashRouter
    if (error.response?.status === 401 && window.location.hash !== '#/login') { 
      console.log('Detected 401 on a protected route. Logging out and redirecting.');
      localStorage.removeItem('authToken');
      localStorage.removeItem('authUser');
      // Redirect to login page using hash format
      window.location.href = '/#/login'; 
    }
    
    // Always reject the promise so component-level .catch() can handle it
    return Promise.reject(error); 
  }
);

// Drugs API
export const drugsAPI = {
  getAll: () => api.get('/drugs'),
  getById: (id) => api.get(`/drugs/${id}`),
  create: (data) => api.post('/drugs', data),
  update: (id, data) => api.put(`/drugs/${id}`, data),
  delete: (id) => api.delete(`/drugs/${id}`),
  getQuotaStatus: (id) => api.get(`/drugs/${id}/quota-status`),
};

// Patients API
export const patientsAPI = {
  getAll: (search) => api.get('/patients', { params: { search } }),
  getById: (id) => api.get(`/patients/${id}`),
  create: (data) => api.post('/patients', data),
  update: (id, data) => api.put(`/patients/${id}`, data),
  delete: (id) => api.delete(`/patients/${id}`),
  getEnrollments: (id) => api.get(`/patients/${id}/enrollments`),
};

// Enrollments API
export const enrollmentsAPI = {
  getAll: (params) => api.get('/enrollments', { params }),
  getById: (id) => api.get(`/enrollments/${id}`),
  create: (data) => api.post('/enrollments', data),
  update: (id, data) => api.put(`/enrollments/${id}`, data),
  delete: (id) => api.delete(`/enrollments/${id}`),
  cleanup: () => api.delete('/enrollments/cleanup'),
  updateRefill: (id, data) => api.patch(`/enrollments/${id}/refill`, data),
  deactivate: (id, data) => api.patch(`/enrollments/${id}/deactivate`, data),
  getPotentialDefaulters: () => api.get('/enrollments/defaulters/potential'),
  moveToDefaulter: (id, data) => api.post(`/enrollments/${id}/move-to-defaulter`, data),
  getYearlyCosts: (params) => api.get('/enrollments/reports/yearly-costs', { params }),
};

// Departments API
export const departmentsAPI = {
  getAll: () => api.get('/departments'),
  getById: (id) => api.get(`/departments/${id}`),
  create: (data) => api.post('/departments', data),
  update: (id, data) => api.put(`/departments/${id}`, data),
  delete: (id) => api.delete(`/departments/${id}`),
  getSummary: (id) => api.get(`/departments/${id}/summary`),
};

// Reports API
export const reportsAPI = {
  getCostAnalysis: (params) => api.get('/reports/cost-analysis', { params }),
  getQuotaUtilization: (params) => api.get('/reports/quota-utilization', { params }),
  getDefaulters: (params) => api.get('/reports/defaulters', { params }),
  getDashboard: () => api.get('/reports/dashboard'),
  exportExcel: (params) => api.get('/reports/export/excel', { 
    params,
    responseType: 'blob'
  }),
};

// Settings API
export const settingsAPI = {
  get: () => api.get('/settings'),      // Needs backend endpoint: GET /api/settings
  update: (data) => api.put('/settings', data), // Needs backend endpoint: PUT /api/settings
};

// Authentication API
export const authAPI = {
  login: (credentials) => api.post('/auth/login', credentials),
  register: (userData) => api.post('/auth/register', userData),
  logout: () => api.post('/auth/logout'),
  verifyToken: () => api.get('/auth/verify'),
  resetPassword: (data) => api.post('/auth/reset-password', data),
  changePassword: (passwords) => api.post('/auth/change-password', passwords),
};

export default api;
