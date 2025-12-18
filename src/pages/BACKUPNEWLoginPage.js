import React, { useState, useEffect } from 'react';
import { Form, Input, Button, Card, Tabs, message, Typography, Checkbox, Alert } from 'antd';
import { UserOutlined, LockOutlined, IdcardOutlined, ClockCircleOutlined } from '@ant-design/icons';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { authAPI } from '../services/api';
import logo from '../img/logo.svg';
import './LoginPage.css';

const { Title, Text } = Typography;
const { TabPane } = Tabs;

const LoginPage = () => {
  const [loading, setLoading] = useState(false);
  const [activeTab, setActiveTab] = useState('login');
  const [rememberMe, setRememberMe] = useState(false);
  const [lastLogin, setLastLogin] = useState(null);
  const navigate = useNavigate();
  const { login, isAuthenticated } = useAuth();

  // Load saved credentials and last login info
  useEffect(() => {
    const savedIcNumber = localStorage.getItem('rememberedIcNumber');
    const lastLoginInfo = localStorage.getItem('lastLoginInfo');

    if (savedIcNumber) {
      setRememberMe(true);
    }

    if (lastLoginInfo) {
      setLastLogin(JSON.parse(lastLoginInfo));
    }
  }, []);

  // Redirect if already authenticated
  useEffect(() => {
    if (isAuthenticated()) {
      navigate('/');
    }
  }, [isAuthenticated, navigate]);

  const handleLogin = async (values) => {
    setLoading(true);
    try {
      const response = await authAPI.login(values);
      // Assuming backend sends { success: true, ... } on successful login
      if (response.data.success) {
        message.success('Login successful!');

        // Handle Remember Me
        if (rememberMe) {
          localStorage.setItem('rememberedIcNumber', values.ic_number);
        } else {
          localStorage.removeItem('rememberedIcNumber');
        }

        // Save last login info
        const loginInfo = {
          timestamp: new Date().toISOString(),
          icNumber: values.ic_number
        };
        localStorage.setItem('lastLoginInfo', JSON.stringify(loginInfo));

        login(response.data.user, response.data.token);
        navigate('/');
      } else {
        // Handle cases where backend returns 200 OK but indicates failure
        message.error(response.data.message || 'Login failed: Unexpected response structure.');
      }
    } catch (error) {
      // Catch network errors or specific HTTP error codes (like 400, 401, 500)
      if (error.response?.status === 401) {
        // Specific message for invalid credentials
        message.error('Invalid IC Number or Password.');
      } else {
        // Generic message for other errors
        message.error(error.response?.data?.message || 'Login failed. Please check connection or try again.');
      }
      console.error('Login specific error:', error.response || error); // Log detailed error
    } finally {
      setLoading(false);
    }
  };


  const handleResetPassword = async (values) => {
    setLoading(true);
    try {
      const response = await authAPI.resetPassword(values);
      if (response.data.success) {
        message.success('Password has been reset! Your new password is the same as your IC Number.');
      } else {
        message.error(response.data.message || 'Failed to reset password');
      }
    } catch (error) {
      message.error(error.response?.data?.message || 'Failed to reset password. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <Card className="login-card">
        <div className="login-logo">
          <img
            src={logo}
            alt="HSQDM Logo"
          />
          <Title level={2} className="login-title">
            QDMS
          </Title>
          <Text type="secondary" className="login-subtitle">
            Quota Drug Management System
            <br />Hospital Segamat
          </Text>
        </div>

        {lastLogin && (
          <div className="last-login-info">
            <ClockCircleOutlined />
            <span>
              Last login: {new Date(lastLogin.timestamp).toLocaleString('en-MY', {
                dateStyle: 'medium',
                timeStyle: 'short'
              })}
            </span>
          </div>
        )}

        <Tabs activeKey={activeTab} onChange={setActiveTab} centered className="login-form">
          <TabPane tab="Login" key="login">
            <Form
              name="login"
              onFinish={handleLogin}
              layout="vertical"
              size="large"
              initialValues={{
                ic_number: localStorage.getItem('rememberedIcNumber') || '',
                remember: !!localStorage.getItem('rememberedIcNumber')
              }}
            >
              <Form.Item
                name="ic_number"
                rules={[
                  { required: true, message: 'Please input your IC Number!' },
                  { pattern: /^\d+$/, message: 'IC Number must contain only numbers (no dashes or special characters)!' }
                ]}
              >
                <Input
                  prefix={<IdcardOutlined />}
                  placeholder="IC Number"
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

              <Form.Item name="remember" valuePropName="checked">
                <Checkbox
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                >
                  Remember me
                </Checkbox>
              </Form.Item>

              <Form.Item>
                <Button
                  type="primary"
                  htmlType="submit"
                  loading={loading}
                  block
                >
                  Login
                </Button>
              </Form.Item>
            </Form>
          </TabPane>

          <TabPane tab="Reset Password" key="reset">
            <Form
              name="resetPassword"
              onFinish={handleResetPassword}
              layout="vertical"
              size="large"
            >
              <Form.Item
                name="ic_number"
                rules={[
                  { required: true, message: 'Please input your IC Number!' },
                  { pattern: /^\d+$/, message: 'IC Number must contain only numbers (no dashes or special characters)!' }
                ]}
              >
                <Input
                  prefix={<IdcardOutlined />}
                  placeholder="Enter your IC Number"
                />
              </Form.Item>

              <Form.Item>
                <Button
                  type="primary"
                  htmlType="submit"
                  loading={loading}
                  style={{ width: '100%', height: '40px' }}
                >
                  Reset Password
                </Button>
              </Form.Item>
            </Form>
          </TabPane>
        </Tabs>

        <div className="prescriber-link">
          <Text type="secondary" style={{ fontSize: '12px', marginBottom: '8px', display: 'block' }}>
            Prescriber Overview is available without login
          </Text>
          <Link
            to="/prescriber-overview"
            onClick={(e) => {
              e.preventDefault();
              window.open(`#/prescriber-overview`, '_blank', 'noopener,noreferrer');
            }}
          >
            View Quota Prescriber Overview →
          </Link>
        </div>
      </Card>
    </div>
  );
};

export default LoginPage;
