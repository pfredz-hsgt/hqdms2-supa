import React, { useState } from 'react';
import { Form, Input, Button, Card, Tabs, message, Typography } from 'antd';
import { UserOutlined, LockOutlined, IdcardOutlined } from '@ant-design/icons';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { authAPI } from '../services/api';
import logo from '../img/logo.svg';

const { Title, Text } = Typography;
const { TabPane } = Tabs;

const LoginPage = () => {
  const [loading, setLoading] = useState(false);
  const [activeTab, setActiveTab] = useState('login');
  const navigate = useNavigate();
  const { login, isAuthenticated, resetPassword } = useAuth();

  // Redirect if already authenticated
  React.useEffect(() => {
    if (isAuthenticated()) {
      navigate('/');
    }
  }, [isAuthenticated, navigate]);

  const handleLogin = async (values) => {
    setLoading(true);
    try {
      const { user, session } = await login(values.email, values.password);
      message.success('Login successful!');
      navigate('/');
    } catch (error) {
      message.error(error.message || 'Login failed.');
      console.error('Login error:', error);
    } finally {
      setLoading(false);
    }
  };


  const handleResetPassword = async (values) => {
    setLoading(true);
    try {
      await resetPassword(values.email);
      message.success('Password reset email sent!');
    } catch (error) {
      message.error(error.message || 'Failed to reset password.');
    } finally {
      setLoading(false);
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
      <Card
        style={{
          width: '100%',
          maxWidth: 400,
          boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1)',
          borderRadius: '12px',
          border: 'none'
        }}
      >
        <div style={{ textAlign: 'center', marginBottom: '15px' }}>
          <img
            src={logo}
            alt="HSQDM Logo"
            style={{
              height: '70px',
              display: 'block',
              margin: '0 auto 0 auto'
            }}
          />
          <Title level={2} style={{ color: '#1890ff', marginBottom: '8px', marginTop: '0px' }}>
            QDMS
          </Title>
          <Text type="secondary">
            Quota Drug Management System
            <br />Hospital Segamat
          </Text>
        </div>

        <Tabs activeKey={activeTab} onChange={setActiveTab} centered>
          <TabPane tab="Login" key="login">
            <Form
              name="login"
              onFinish={handleLogin}
              layout="vertical"
              size="large"
              initialValues={{}}
            >
              <Form.Item
                name="email"
                rules={[
                  { required: true, message: 'Please input your Email!' },
                  { type: 'email', message: 'Please enter a valid email!' }
                ]}
              >
                <Input
                  prefix={<UserOutlined />}
                  placeholder="Email"
                />
              </Form.Item>

              <Form.Item
                name="password"
                rules={[
                  { required: true, message: 'Please input your password!' },
                  { min: 4, message: 'Password must be at least 4 characters!' }
                ]}
              >
                <Input.Password
                  prefix={<LockOutlined />}
                  placeholder="Password"
                />
              </Form.Item>

              <Form.Item>
                <Button
                  type="primary"
                  htmlType="submit"
                  loading={loading}
                  style={{ width: '100%', height: '40px' }}
                >
                  Login
                </Button>
              </Form.Item>
            </Form>
          </TabPane>

          {/* Removed Reset Password tab for now as it requires complex flow */}
        </Tabs>

        <div style={{ textAlign: 'center', marginTop: '16px' }}>
          <Text type="secondary" style={{ fontSize: '12px', marginBottom: '8px', display: 'block' }}>
            Prescriber Overview is available without login
          </Text>
          <Link
            to="/prescriber-overview"
            target="_blank"
            rel="noopener noreferrer"
            style={{ fontSize: '14px', fontWeight: '500', color: '#1890ff' }}
          >
            View Quota Prescriber Overview →
          </Link>
        </div>
      </Card>
    </div>
  );
};

export default LoginPage;
