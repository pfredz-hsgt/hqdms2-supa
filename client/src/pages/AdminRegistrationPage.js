import React, { useState } from 'react';
import { Form, Input, Button, Card, message, Typography, Space, Alert, Switch, Divider, Skeleton, Modal, Tabs } from 'antd'; // 1. Import Modal
import { UserOutlined, LockOutlined, IdcardOutlined, UserAddOutlined, SettingOutlined, LoginOutlined } from '@ant-design/icons'; // 2. Import LoginOutlined
import { useNavigate } from 'react-router-dom';
import { authAPI } from '../services/api';
import { useSettings } from '../contexts/SettingsContext';

const { Title, Text } = Typography;

const SettingsSwitch = ({ title, description, settingKey, loading, settings, onChange }) => {
  if (loading || !settings) {
    return <Skeleton.Input active style={{ width: '100%', marginBottom: '16px' }} />;
  }
  
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
      <div>
        <Text strong>{title}</Text>
        <br />
        <Text type="secondary">{description}</Text>
      </div>
      <Switch
        checked={settings[settingKey]}
        onChange={(checked) => onChange(settingKey, checked)}
      />
    </div>
  );
};


const AdminRegistrationPage = () => {
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const [form] = Form.useForm();
  
  const { settings, loading: settingsLoading, updateSettings } = useSettings();

  const [isAuthorized, setIsAuthorized] = useState(false);
  const [authModalVisible, setAuthModalVisible] = useState(true); 
  const [authLoading, setAuthLoading] = useState(false);
  const [authForm] = Form.useForm();

  const handleRegister = async (values) => {
      setLoading(true);
      try {
         const response = await authAPI.register(values);
         if (response.data.success) {
            message.success('User registered successfully!');
            // Reset form
            form.resetFields();
         } else {
            message.error(response.data.message || 'Registration failed');
         }
      } catch (error) {
         message.error(error.response?.data?.message || 'Registration failed. Please try again.');
      } finally {
         setLoading(false);
      }
  };

  const handleSettingChange = async (key, value) => {
      try {
         await updateSettings({ [key]: value });
         message.success('System setting updated!');
      } catch (error) {
         message.error('Failed to update setting. Please try again.');
      }

  };

  // --- 4. Add a handler for the new auth modal ---
  const handleAuth = (values) => {
    setAuthLoading(true);
    if (values.username === 'admin' && values.password === 'admin') {
      // Simulate a small delay for better UX
      setTimeout(() => {
        message.success('Access Granted');
        setIsAuthorized(true);
        setAuthModalVisible(false);
        setAuthLoading(false);
      }, 500);
    } else {
      setTimeout(() => {
        message.error('Incorrect Username or Password');
        authForm.resetFields(['password']); // Only clear the password field
        setAuthLoading(false);
      }, 500);
    }
  };

return (
    <div style={{
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px'
    }}>

      {/* --- Authorization Modal --- */}
      {/* This modal will show on top and block content until authorized */}
      <Modal
        title={<div style={{ textAlign: 'center', width: '100%', fontSize: '20px' }}>Administrator Control Panel</div>}
        open={authModalVisible}
        closable={false}
        keyboard={false}
        width={350}
        centered
        footer={null}
      >
        <Text type="secondary" style={{ marginBottom: '24px', display: 'block' }}>
          This page is restricted to Administrator only.
        </Text>
        <Form
          form={authForm}
          onFinish={handleAuth}
          layout="vertical"
        >
          <Form.Item
            name="username"
            label="Username"
            rules={[{ required: true, message: 'Please enter the username' }]}
          >
            <Input prefix={<UserOutlined />} placeholder="Username" />
          </Form.Item>
          <Form.Item
            name="password"
            label="Password"
            rules={[{ required: true, message: 'Please enter the password' }]}
          >
            <Input.Password prefix={<LockOutlined />} placeholder="Password" />
          </Form.Item>
          <Form.Item>
            <Space style={{ width: '100%', justifyContent: 'space-between' }}>
              <Button
                type="default"
                onClick={() => navigate('/home')} 
              >
                Back to Home
              </Button>
              <Button
                type="primary"
                htmlType="submit"
                loading={authLoading}
                icon={<LoginOutlined />}
              >
                Authorize
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>

      {/* --- Conditionally Render Main Content --- */}
      {isAuthorized && (
        <Tabs
          defaultActiveKey="new-registration"
          type="card" // Use "card" type for a nice container
          style={{
            width: '100%',
            maxWidth: 500,
            background: 'var(--bg-primary)',
            borderRadius: 'var(--radius-lg)',
            boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1)',
            border: 'none',
          }}
          items={[
            // --- TAB 1: NEW REGISTRATION ---
            {
              key: 'new-registration',
              label: (
                <span style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <UserAddOutlined /> New Registration
                </span>
              ),
              children: (
                <div style={{ padding: '24px' }}>
                  {/* === USER REGISTRATION FORM === */}
                  <div style={{ textAlign: 'center', marginBottom: '24px' }}>
                    <UserAddOutlined style={{ fontSize: '48px', color: '#1890ff', marginBottom: '16px' }} />
                    <Title level={2} style={{ color: '#1890ff', marginBottom: '8px' }}>
                      New User Registration
                    </Title>
                    <Text type="secondary">
                      Register new users for QDMS
                    </Text>
                  </div>
                  <Form
                    form={form}
                    name="adminRegister"
                    onFinish={handleRegister}
                    layout="vertical"
                    size="large"
                  >
                    <Form.Item name="name" rules={[{ required: true, message: 'Please input the user\'s name!' }, { min: 5, message: 'Name must have at least 5 characters!' }]} >
                      <Input prefix={<UserOutlined />} placeholder="Full Name" />
                    </Form.Item>
                    <Form.Item name="ic_number" rules={[{ required: true, message: 'Please input the IC Number!' }, { pattern: /^\d+$/, message: 'IC Number must contain only numbers (no dashes or special characters)!' }]} >
                      <Input prefix={<IdcardOutlined />} placeholder="IC Number" />
                    </Form.Item>
                    <Form.Item name="password" rules={[{ required: true, message: 'Please input a password!' }, { min: 4, message: 'Password must be at least 4 characters!' }]} >
                      <Input.Password prefix={<LockOutlined />} placeholder="Password" />
                    </Form.Item>
                    <Form.Item name="confirmPassword" dependencies={['password']} rules={[{ required: true, message: 'Please confirm the password!' }, ({ getFieldValue }) => ({ validator(_, value) { if (!value || getFieldValue('password') === value) { return Promise.resolve(); } return Promise.reject(new Error('Passwords do not match!')); }, }), ]} >
                      <Input.Password prefix={<LockOutlined />} placeholder="Confirm Password" />
                    </Form.Item>
                    <Form.Item>
                      <Space direction="vertical" style={{ width: '100%' }}>
                        <Button type="primary" htmlType="submit" loading={loading} style={{ width: '100%', height: '40px' }} icon={<UserAddOutlined />}>
                          Register User
                        </Button>
                      </Space>
                    </Form.Item>
                  </Form>
                </div>
              )
            },
            // --- TAB 2: SYSTEM SETTINGS ---
            {
              key: 'admin-settings',
              label: (
                <span style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <SettingOutlined /> System Settings
                </span>
              ),
              children: (
                <div style={{ padding: '24px' }}>
                  {/* === SYSTEM SETTINGS === */}
                  <div style={{ textAlign: 'center', marginBottom: '24px' }}>
                    <SettingOutlined style={{ fontSize: '48px', color: '#722ed1', marginBottom: '16px' }} />
                    <Title level={2} style={{ color: '#722ed1', marginBottom: '8px' }}>
                      System Settings
                    </Title>
                    <Text type="secondary">
                      Globally enable or disable creation of new items
                    </Text>
                  </div>
                  
                  <SettingsSwitch title="Allow New Enrollments" description="Enable or disable adding new enrollments on all pages" settingKey="allowNewEnrollments" loading={settingsLoading} settings={settings} onChange={handleSettingChange} />
                  <SettingsSwitch title="Allow New Drugs" description="Enable or disable adding new drugs to the system" settingKey="allowNewDrugs" loading={settingsLoading} settings={settings} onChange={handleSettingChange} />
                  <SettingsSwitch title="Allow New Departments" description="Enable or disable adding new departments" settingKey="allowNewDepartments" loading={settingsLoading} settings={settings} onChange={handleSettingChange} />
                  <SettingsSwitch title="Allow New Patients" description="Enable or disable creating new patients" settingKey="allowNewPatients" loading={settingsLoading} settings={settings} onChange={handleSettingChange} />
                  
                  <Button type="default" onClick={() => navigate('/login')} style={{ width: '100%', height: '40px', marginTop: '24px' }}>
                    Back to Home
                  </Button>
                </div>
              )
            }
          ]}
        />
      )} 
    </div>
  );
};

export default AdminRegistrationPage;