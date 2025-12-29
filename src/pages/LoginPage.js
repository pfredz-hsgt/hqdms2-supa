import React, { useState } from 'react';
import { Form, Input, Button, Card, Tabs, message, Typography, Divider } from 'antd';
import { LockOutlined, IdcardOutlined } from '@ant-design/icons'; // Changed UserOutlined to IdcardOutlined
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import logo from '../img/logo.svg';

const { Title, Text } = Typography;
const { TabPane } = Tabs;

const LoginPage = () => {
  const [loading, setLoading] = useState(false);
  const [activeTab, setActiveTab] = useState('login');
  const navigate = useNavigate();
  const { login, isAuthenticated } = useAuth();

  // Redirect if already authenticated
  React.useEffect(() => {
    if (isAuthenticated()) {
      navigate('/');
    }
  }, [isAuthenticated, navigate]);

  const handleLogin = async (values) => {
    setLoading(true);
    try {
      // 1. Transform IC Number into the internal "fake email" format
      const fakeEmail = `${values.ic_number}@hqdms.com`;

      // 2. Pass the transformed email to your auth context
      await login(fakeEmail, values.password);

      message.success('Login successful!');
      navigate('/');
    } catch (error) {
      // Friendly error for local users
      const errorMsg = error.message === 'Invalid login credentials'
        ? 'Invalid IC Number or Password'
        : error.message;

      message.error(errorMsg || 'Login failed.');
      console.error('Login error:', error);
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
          <TabPane tab="Staff Login" key="login">
            <Form
              name="login"
              onFinish={handleLogin}
              layout="vertical"
              size="large"
            >
              {/* Changed from Email to IC Number */}
              <Form.Item
                name="ic_number"
                label="IC Number"
                rules={[
                  { required: true, message: 'Please input your IC Number!' },
                  { pattern: /^\d+$/, message: 'Please enter numbers only' },
                  { min: 6, message: 'IC Number is too short' }
                ]}
              >
                <Input
                  prefix={<IdcardOutlined style={{ color: 'rgba(0,0,0,.25)' }} />}
                  placeholder="Example: 950101145566"
                />
              </Form.Item>

              <Form.Item
                name="password"
                label="Password"
                rules={[
                  { required: true, message: 'Please input your password!' }
                ]}
              >
                <Input.Password
                  prefix={<LockOutlined style={{ color: 'rgba(0,0,0,.25)' }} />}
                  placeholder="Password"
                />
              </Form.Item>

              <Form.Item>
                <Button
                  type="primary"
                  htmlType="submit"
                  loading={loading}
                  style={{ width: '100%', height: '40px', marginTop: '10px' }}
                >
                  Sign In
                </Button>
              </Form.Item>
            </Form>
          </TabPane>
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