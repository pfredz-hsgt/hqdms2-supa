import React, { useState } from 'react';
import { Form, Input, Button, message, Typography, Space, Switch, Skeleton, Modal, Tabs, Divider } from 'antd';
import { UserOutlined, LockOutlined, IdcardOutlined, UserAddOutlined, SettingOutlined, LoginOutlined, SolutionOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
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
  const { register } = useAuth();

  const { settings, loading: settingsLoading, updateSettings, fetchSettings } = useSettings();
  const [isAuthorized, setIsAuthorized] = useState(false);
  const [authModalVisible, setAuthModalVisible] = useState(true);
  const [authLoading, setAuthLoading] = useState(false);
  const [authForm] = Form.useForm();

  // Fetch settings on mount
  React.useEffect(() => {
    fetchSettings();
  }, [fetchSettings]);

  // --- UPDATED HANDLER FOR OPTION 1 ---
  const handleRegister = async (values) => {
    setLoading(true);
    try {
      const { ic_number, full_name, password } = values;

      // Construct the dummy email
      const fakeEmail = `${ic_number}@hqdms.com`;

      // Pass name and IC as metadata to the register function
      // Note: Ensure your AuthContext's register function accepts metadata
      // If it doesn't, you'll need to update AuthContext.js (see note below)
      await register(fakeEmail, password, {
        full_name: full_name,
        ic_number: ic_number
      });

      message.success(`User ${full_name} registered successfully!`);
      form.resetFields();
    } catch (error) {
      message.error(error.message || 'Registration failed.');
    } finally {
      setLoading(false);
    }
  };

  const handleSettingChange = async (key, value) => {
    try {
      await updateSettings({ [key]: value });
      message.success('System setting updated!');
    } catch (error) {
      message.error('Failed to update setting.');
    }
  };

  const handleAuth = (values) => {
    setAuthLoading(true);
    if (values.password === 'admin') {
      setTimeout(() => {
        message.success('Access Granted');
        setIsAuthorized(true);
        setAuthModalVisible(false);
        setAuthLoading(false);
      }, 500);
    } else {
      setTimeout(() => {
        message.error('Incorrect Admin Password');
        authForm.resetFields(['password']);
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

      <Modal
        title={<div style={{ textAlign: 'center', width: '100%', fontSize: '20px' }}>Administrator Control Panel</div>}
        open={authModalVisible}
        closable={false}
        keyboard={false}
        width={350}
        centered
        footer={null}
      >
        <Text type="secondary" style={{ marginBottom: '24px', display: 'block', textAlign: 'center' }}>
          Please enter the admin password to proceed.
        </Text>
        <Form form={authForm} onFinish={handleAuth} layout="vertical">
          <Form.Item name="password" label="Admin Password" rules={[{ required: true }]}>
            <Input.Password autoFocus prefix={<LockOutlined />} placeholder="********" />
          </Form.Item>
          <Form.Item>
            <Space style={{ width: '100%', justifyContent: 'space-between' }}>
              <Button type="default" onClick={() => navigate('/')}>Back to Home</Button>
              <Button type="primary" htmlType="submit" loading={authLoading} icon={<LoginOutlined />}>Authorize</Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>

      {isAuthorized && (
        <Tabs
          defaultActiveKey="new-registration"
          type="card"
          style={{
            width: '100%',
            maxWidth: 500,
            background: '#ffffff',
            borderRadius: '12px',
            boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1)',
            overflow: 'hidden'
          }}
          items={[
            {
              key: 'new-registration',
              label: (<span><UserAddOutlined /> New Registration</span>),
              children: (
                <div style={{ padding: '24px' }}>
                  <div style={{ textAlign: 'center', marginBottom: '24px' }}>
                    <SolutionOutlined style={{ fontSize: '48px', color: '#1890ff', marginBottom: '16px' }} />
                    <Title level={2} style={{ color: '#1890ff', marginBottom: '8px' }}>Create User Account</Title>
                    <Text type="secondary">System will use IC Number as the login ID</Text>
                  </div>
                  <Form
                    form={form}
                    name="adminRegister"
                    onFinish={handleRegister}
                    layout="vertical"
                    size="large"
                    className="compact-form"
                  >
                    {/* FULL NAME */}
                    <Form.Item
                      name="full_name"
                      label="Full Name"
                      rules={[{ required: true, message: 'Please input the full name!' }]}
                    >
                      <Input prefix={<UserOutlined />} placeholder="e.g. Ahmad bin Zaki" />
                    </Form.Item>

                    {/* IC NUMBER */}
                    <Form.Item
                      name="ic_number"
                      label="IC Number (Login ID)"
                      rules={[
                        { required: true, message: 'Please input the IC Number!' },
                        { pattern: /^\d+$/, message: 'IC should only contain numbers' }
                      ]}
                    >
                      <Input prefix={<IdcardOutlined />} placeholder="e.g. 950101145566" />
                    </Form.Item>

                    {/* PASSWORD */}
                    <Form.Item
                      name="password"
                      label="Password"
                      rules={[{ required: true, message: 'Please input a password!' }, { min: 6, message: 'Min 6 characters' }]}
                    >
                      <Input.Password prefix={<LockOutlined />} placeholder="Password" />
                    </Form.Item>

                    <Form.Item>
                      <Button type="primary" htmlType="submit" loading={loading} style={{ width: '100%', marginTop: '10px' }} icon={<UserAddOutlined />}>
                        Register New User
                      </Button>
                      <Button type="default" onClick={() => navigate('/')} style={{ width: '100%', marginTop: '10px' }}>
                        Back to Home
                      </Button>
                    </Form.Item>

                  </Form>

                </div>
              )
            },
            {
              key: 'admin-settings',
              label: (<span><SettingOutlined /> System Settings</span>),
              children: (
                <div style={{ padding: '24px' }}>
                  <div style={{ textAlign: 'center', marginBottom: '24px' }}>
                    <SettingOutlined style={{ fontSize: '48px', color: '#722ed1', marginBottom: '16px' }} />
                    <Title level={2} style={{ color: '#722ed1', marginBottom: '8px' }}>System Control</Title>
                  </div>
                  <SettingsSwitch title="Allow New Enrollments" description="Enable or disable adding new enrollments" settingKey="allowNewEnrollments" loading={settingsLoading} settings={settings} onChange={handleSettingChange} />
                  <SettingsSwitch title="Allow New Drugs" description="Enable or disable adding new drugs" settingKey="allowNewDrugs" loading={settingsLoading} settings={settings} onChange={handleSettingChange} />
                  <SettingsSwitch title="Allow New Departments" description="Enable or disable adding new departments" settingKey="allowNewDepartments" loading={settingsLoading} settings={settings} onChange={handleSettingChange} />
                  <SettingsSwitch title="Allow New Patients" description="Enable or disable creating new patients" settingKey="allowNewPatients" loading={settingsLoading} settings={settings} onChange={handleSettingChange} />
                  <Divider />
                  <Button type="default" size="large" onClick={() => navigate('/')} style={{ width: '100%' }}>
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