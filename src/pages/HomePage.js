import React, { useState, useEffect } from 'react';
import {
  Card,
  Input,
  Button,
  Typography,
  Row,
  Col,
  Statistic,
  Alert,
  Space,
  Divider,
  Skeleton
} from 'antd';
import {
  SearchOutlined,
  MedicineBoxOutlined,
  UserOutlined,
  FileTextOutlined,
  ClockCircleOutlined,
  FileExclamationOutlined
} from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { reportsAPI } from '../services/api';
import CountUp from 'react-countup';
import logo from '../img/logo2.svg';

const { Title, Paragraph } = Typography;
const { Search } = Input;

const HomePage = () => {
  const navigate = useNavigate();
  const [searchValue, setSearchValue] = useState('');
  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setError(null);
      const response = await reportsAPI.getDashboard();
      setDashboardData(response.data);
    } catch (error) {
      const errorMessage = error.response?.data?.message || error.message || 'Failed to load dashboard data. Please try again.';
      setError(errorMessage);
      console.error('Error fetching dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (value) => {
    if (value.trim()) {
      navigate(`/refill?search=${encodeURIComponent(value.trim())}`);
    }
  };

  const quickActions = [
    {
      title: 'Quick Refill Update',
      description: 'Update patient refill dates quickly',
      icon: <SearchOutlined style={{ fontSize: '24px', color: '#1890ff' }} />,
      action: () => navigate('/refill'),
      color: '#1890ff'
    },
    {
      title: 'Quota Management',
      description: 'Manage patient enrollments',
      icon: <UserOutlined style={{ fontSize: '24px', color: '#faad14' }} />,
      action: () => navigate('/enrollments'),
      color: '#faad14'
    },
    {
      title: 'Drug List',
      description: 'Manage quota drugs and settings',
      icon: <MedicineBoxOutlined style={{ fontSize: '24px', color: '#f5222d' }} />,
      action: () => navigate('/drugs'),
      color: '#f5222d'
    },
    {
      title: 'Reports & Analytics',
      description: 'Generate reports and export data',
      icon: <FileTextOutlined style={{ fontSize: '24px', color: '#722ed1' }} />,
      action: () => navigate('/reports'),
      color: '#722ed1'
    }
  ];

  return (
    <div style={{ padding: '24px' }}>
      {/* Welcome Section */}
      <div className="search-container">
        <img
          src={logo}
          alt="HSQDM Logo"
          style={{
            height: '140px', // Adjust size based on collapsed state
            marginBottom: '4px', // Add space below logo
            display: 'block', // Center the image
            margin: '0 auto 4px auto' // Center and add bottom margin
          }}
        />
        <Title level={2} className="search-title">
          Quota Drug Management System <br /> Hospital Segamat
        </Title>
        <Paragraph style={{ textAlign: 'center', fontSize: '16px', color: '#666', marginBottom: '32px' }}>
          © Jabatan Farmasi Hospital Segamat 2025
        </Paragraph>

        <Search
          placeholder="Search by patient name or IC number for quick refill update"
          enterButton={<SearchOutlined />}
          size="large"
          value={searchValue}
          onChange={(e) => setSearchValue(e.target.value)}
          onSearch={handleSearch}
          className="search-bar search-bar-lg"
          style={{ maxWidth: '600px', margin: '0 auto' }}
        />
      </div>

      {/* Error Alert */}
      {error && !loading && (
        <Alert
          message="Error Loading Dashboard"
          description={error}
          type="error"
          showIcon
          action={
            <Button size="small" onClick={fetchDashboardData}>
              Retry
            </Button>
          }
          closable
          onClose={() => setError(null)}
          style={{ marginBottom: '24px' }}
        />
      )}

      {/* Dashboard Stats */}
      {loading ? (
        <Card style={{ marginBottom: '24px' }}>
          <Skeleton active paragraph={{ rows: 2 }} />
        </Card>
      ) : dashboardData ? (
        <Card style={{ marginTop: '8px', marginBottom: '24px', background: 'linear-gradient(135deg, #ffffff 0%, #f9fafb 100%)' }} className="card">
          <Title level={4} style={{ marginTop: '8px', marginBottom: '16px' }}>
            <ClockCircleOutlined style={{ marginRight: '8px' }} />
            System Overview
          </Title>
          <Row gutter={16}>
            <Col xs={12} sm={6} style={{ textAlign: 'center' }}>
              <div style={{ padding: '16px', borderRadius: '8px', background: '#eff6ff' }}>
                <div style={{ fontSize: '32px', fontWeight: '700', color: '#3b82f6', marginBottom: '8px' }}>
                  <CountUp end={dashboardData.total_departments} duration={2} />
                </div>
                <div style={{ color: '#6b7280', fontSize: '14px', fontWeight: '500' }}>Departments</div>
              </div>
            </Col>
            <Col xs={12} sm={6} style={{ textAlign: 'center' }}>
              <div style={{ padding: '16px', borderRadius: '8px', background: '#d1fae5' }}>
                <div style={{ fontSize: '32px', fontWeight: '700', color: '#10b981', marginBottom: '8px' }}>
                  <CountUp end={dashboardData.total_drugs} duration={2} />
                </div>
                <div style={{ color: '#6b7280', fontSize: '14px', fontWeight: '500' }}>Quota Drugs</div>
              </div>
            </Col>
            <Col xs={12} sm={6} style={{ textAlign: 'center' }}>
              <div style={{ padding: '16px', borderRadius: '8px', background: '#ede9fe' }}>
                <div style={{ fontSize: '32px', fontWeight: '700', color: '#8b5cf6', marginBottom: '8px' }}>
                  <CountUp end={dashboardData.active_enrollments} duration={2} />
                </div>
                <div style={{ color: '#6b7280', fontSize: '14px', fontWeight: '500' }}>Active Enrollments</div>
              </div>
            </Col>
            <Col xs={12} sm={6} style={{ textAlign: 'center' }}>
              <div style={{ padding: '16px', borderRadius: '8px', background: '#fef3c7' }}>
                <div style={{ fontSize: '32px', fontWeight: '700', color: '#f59e0b', marginBottom: '8px' }}>
                  <CountUp end={dashboardData.total_quota} duration={2} />
                </div>
                <div style={{ color: '#6b7280', fontSize: '14px', fontWeight: '500' }}>Quota Available</div>
              </div>
            </Col>
          </Row>
        </Card>
      ) : null}

      {/* Today's Summary */}
      {loading ? (
        <Card style={{ marginBottom: '24px' }}>
          <Skeleton active paragraph={{ rows: 3 }} />
        </Card>
      ) : dashboardData ? (
        <Card style={{ marginTop: '8px', marginBottom: '24px' }} className="card">
          <Title level={4} style={{ marginTop: '8px', marginBottom: '16px' }}>
            <ClockCircleOutlined style={{ marginRight: '8px' }} />
            Today's Summary
          </Title>
          <Row gutter={[16, 16]}>
            <Col xs={24} sm={8} style={{ textAlign: 'center' }}>
              <Statistic
                title="Refills Processed"
                value={dashboardData.recent_refills || 0}
                prefix={<ClockCircleOutlined />}
                valueStyle={{ color: '#1890ff' }}
                formatter={(value) => <CountUp end={value} duration={2} />}
              />
            </Col>
            <Col xs={24} sm={8} style={{ textAlign: 'center' }}>
              <Statistic
                title="Annual Cost"
                value={parseFloat(dashboardData.total_annual_cost)}
                prefix="RM "
                precision={2}
                valueStyle={{ color: '#52c41a' }}
                formatter={(value) => <CountUp end={value} duration={2} decimals={2} separator="," />}
              />
            </Col>
            <Col xs={24} sm={8} style={{ textAlign: 'center' }}>
              <Statistic
                title="Defaulters Detected"
                value={dashboardData.potential_defaulters}
                prefix={<FileExclamationOutlined />}
                valueStyle={{ color: '#fa8c16' }}
                formatter={(value) => <CountUp end={value} duration={2} />}
              />
            </Col>
          </Row>

          <Divider />

          <div>
            <Paragraph type="secondary" style={{ textAlign: 'center' }}>
              System Performance: All services running normally.
            </Paragraph>
          </div>
        </Card>
      ) : null}

      {/* Quick Actions */}
      <Card title="Quick Actions" style={{ marginTop: '8px', marginBottom: '24px' }} className="card">
        <Row gutter={[16, 16]}>
          {quickActions.map((action, index) => (
            <Col xs={24} sm={12} md={8} lg={6} key={index}>
              <Card
                hoverable
                onClick={action.action}
                style={{
                  textAlign: 'center',
                  border: `2px solid ${action.color} 20`,
                  borderRadius: '8px',
                  height: '150px'
                }}
                bodyStyle={{ padding: '20px' }}
              >
                <Space direction="vertical" size="middle" style={{ width: '100%' }}>
                  {action.icon}
                  <div>
                    <Title level={5} style={{ margin: 0, color: action.color }}>
                      {action.title}
                    </Title>
                    <Paragraph style={{ margin: '8px 0 0 0', color: '#666', fontSize: '12px' }}>
                      {action.description}
                    </Paragraph>
                  </div>
                </Space>
              </Card>
            </Col>
          ))}
        </Row>
      </Card>

    </div>
  );
};

export default HomePage;
