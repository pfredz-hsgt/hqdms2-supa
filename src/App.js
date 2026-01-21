import React, { useState, useEffect } from 'react';
import { Routes, Route, useLocation, useNavigate } from 'react-router-dom';
import { Layout, Menu, Typography } from 'antd';
import {
  HomeOutlined,
  UserOutlined,
  MedicineBoxOutlined,
  FileTextOutlined,
  SearchOutlined,
  BankOutlined,
  TeamOutlined
} from '@ant-design/icons';
import { App as CapacitorApp } from '@capacitor/app';
import { StatusBar, Style } from '@capacitor/status-bar';
import { AuthProvider } from './contexts/AuthContext';
import { SettingsProvider } from './contexts/SettingsContext';
import ProtectedRoute from './components/ProtectedRoute';
import HeaderWithAuth from './components/HeaderWithAuth';
import BreadcrumbNav from './components/BreadcrumbNav';

// Import pages
import HomePage from './pages/HomePage';
import SummaryPage from './pages/SummaryPage';
import PatientListPage from './pages/PatientListPage';
import DrugListPage from './pages/DrugListPage';
import DepartmentListPage from './pages/DepartmentListPage';
import ReportsPage from './pages/ReportsPage';
import RefillUpdatePage from './pages/RefillUpdatePage';
import EnrollmentListPage from './pages/EnrollmentListPage';
import PrescriberOverviewPage from './pages/PrescriberOverviewPage';
import LoginPage from './pages/LoginPage';
import AdminRegistrationPage from './pages/AdminRegistrationPage';
import logo from './img/logo.svg';

const { Sider, Content, Footer } = Layout;
const { Title, Text } = Typography;

// Main App Layout Component
function AppLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const [collapsed, setCollapsed] = useState(false);
  const [currentCollapsedWidth, setCurrentCollapsedWidth] = useState(60);


  const menuItems = [
    {
      key: '/',
      icon: <HomeOutlined />,
      label: 'Home',
    },
    {
      key: '/refill',
      icon: <SearchOutlined />,
      label: 'Quick Refill',
    },
    {
      key: '/enrollments',
      icon: <TeamOutlined />,
      label: 'Enrollments',
    },
    {
      key: '/drugs',
      icon: <MedicineBoxOutlined />,
      label: 'Drug List',
    },
    {
      key: '/patients',
      icon: <UserOutlined />,
      label: 'Patient List',
    },
    {
      key: '/departments',
      icon: <BankOutlined />,
      label: 'Departments',
    },
    {
      key: '/reports',
      icon: <FileTextOutlined />,
      label: 'Reports',
    },
    {
      key: '/prescriber-overview',
      icon: <BankOutlined />,
      label: 'Prescriber Overview',

    },
  ];

  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth < 576) {
        setCurrentCollapsedWidth(0);
      } else {
        setCurrentCollapsedWidth(60);
      }
    };

    handleResize();

    window.addEventListener('resize', handleResize);

    return () => window.removeEventListener('resize', handleResize);
  }, []); // Empty array ensures this runs only once on mount

  // Configure status bar for Android
  useEffect(() => {
    const configureStatusBar = async () => {
      try {
        await StatusBar.setStyle({ style: Style.Light });
        await StatusBar.setBackgroundColor({ color: '#ffffff' });
      } catch (error) {
        // StatusBar not available (running in browser)
        console.log('StatusBar not available');
      }
    };

    configureStatusBar();
  }, []);

  // Handle Android back button
  useEffect(() => {
    let backButtonListener;

    const setupBackButton = async () => {
      try {
        backButtonListener = await CapacitorApp.addListener('backButton', ({ canGoBack }) => {
          // If on login page or home page, exit app
          if (location.pathname === '/login' || location.pathname === '/') {
            CapacitorApp.exitApp();
          }
          // If can go back in history, go back
          else if (canGoBack) {
            window.history.back();
          }
          // Otherwise exit app
          else {
            CapacitorApp.exitApp();
          }
        });
      } catch (error) {
        // Back button not available (running in browser)
        console.log('Back button listener not available');
      }
    };

    setupBackButton();

    // Cleanup listener on unmount
    return () => {
      if (backButtonListener) {
        backButtonListener.remove();
      }
    };
  }, [location.pathname]);

  const handleMenuClick = ({ key }) => {
    if (key === '/prescriber-overview') {
      window.open(`#${key}`, '_blank', 'noopener,noreferrer');
    } else {
      navigate(key);
    }

    // Auto-collapse menu only on narrow screens (mobile/tablet)
    if (window.innerWidth < 992) {
      setCollapsed(true);
    }
  };

  // Check if current page should hide sidebar
  const hideSidebar = location.pathname === '/prescriber-overview';

  return (
    <Layout style={{ minHeight: '100vh' }}>
      {!hideSidebar && (
        <Sider
          width={225}
          collapsed={collapsed}
          onCollapse={setCollapsed}
          breakpoint="lg"
          collapsedWidth={currentCollapsedWidth}
          collapsible
          style={{
            background: '#fff',
            boxShadow: '2px 0 8px rgba(0, 0, 0, 0.1)',
            position: 'sticky',
            top: 0,
            height: '100vh',
            zIndex: 1000,
          }}
        >
          <div style={{
            padding: collapsed ? '16px 8px' : '24px 16px',
            textAlign: 'center',
            borderBottom: '1px solid #f0f0f0'
          }}>
            <img
              src={logo}
              alt="QDMS Logo"
              style={{
                height: collapsed ? '32px' : '60px',
                marginBottom: collapsed ? '8px' : '8px',
                display: 'block',
                margin: '0 auto 12px auto'
              }}
            />
            <Title level={4} style={{ margin: 0, color: '#1890ff', fontSize: '24px' }}>
              {collapsed ? ' ' : 'QDMS'}
            </Title>
            {!collapsed && (
              <div style={{ fontSize: '12px', color: '#666', marginTop: '4px' }}>
                Quota Drug Management System
                Hospital Segamat
              </div>
            )}
          </div>
          <Menu
            mode="inline"
            selectedKeys={[location.pathname]}
            items={menuItems}
            onClick={handleMenuClick}
            style={{
              border: 'none',
              background: '#fff'
            }}
          />
        </Sider>
      )}

      <Layout>
        {/* Header - Hidden for prescriber overview */}
        {!hideSidebar && <HeaderWithAuth />}

        <Content>
          {!hideSidebar && <BreadcrumbNav />}
          <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route path="/regist" element={<AdminRegistrationPage />} />
            <Route path="/" element={<ProtectedRoute><HomePage /></ProtectedRoute>} />
            <Route path="/refill" element={<ProtectedRoute><RefillUpdatePage /></ProtectedRoute>} />
            <Route path="/summary" element={<ProtectedRoute><SummaryPage /></ProtectedRoute>} />
            <Route path="/prescriber-overview" element={<PrescriberOverviewPage />} />
            <Route path="/enrollments" element={<ProtectedRoute><EnrollmentListPage /></ProtectedRoute>} />
            <Route path="/patients" element={<ProtectedRoute><PatientListPage /></ProtectedRoute>} />
            <Route path="/drugs" element={<ProtectedRoute><DrugListPage /></ProtectedRoute>} />
            <Route path="/departments" element={<ProtectedRoute><DepartmentListPage /></ProtectedRoute>} />
            <Route path="/reports" element={<ProtectedRoute><ReportsPage /></ProtectedRoute>} />
          </Routes>
        </Content>

        <Footer style={{
          textAlign: 'center',
          padding: '16px',
          background: 'transparent', // Make it blend with the gradient
          color: 'var(--text-primary)'  // Use the light text color
        }}>
          <Text style={{ color: 'var(--text-secondary)' }}>
            QDMS - Quota Drug Management System Hospital Segamat
            Version: 0.8.0 (Beta)
            <br />
            Sebarang Pertanyaan,  sila hubungi: Unit Maklumat Ubat di talian samb. 325 atau emel: farmasihsegamat@moh.gov.my
            <br />
            © {new Date().getFullYear()} Jabatan Farmasi Hospital Segamat. All Rights Reserved.
          </Text>
        </Footer>



      </Layout>
    </Layout>
  );
}

// Main App Component with Authentication
function App() {
  const location = useLocation();

  // Show login page without layout
  if (location.pathname === '/login') {
    return <LoginPage />;
  }

  // Show admin registration page without layout
  if (location.pathname === '/regist') {
    return <AdminRegistrationPage />;
  }

  // Show app layout for all other pages
  return <AppLayout />;
}

// App with AuthProvider wrapper
function AppWithAuth() {
  return (
    <AuthProvider>
      <SettingsProvider>
        <App />
      </SettingsProvider>
    </AuthProvider>
  );
}

export default AppWithAuth;
