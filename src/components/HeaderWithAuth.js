import React, { useState, useEffect } from 'react';
import { Layout, Typography, Space, Button, Tooltip } from 'antd';
import { useLocation } from 'react-router-dom';
import { QuestionCircleOutlined } from '@ant-design/icons';
import UserProfile from './UserProfile';
import KeyboardShortcutsModal from './KeyboardShortcutsModal';

const { Header } = Layout;
const { Title } = Typography;

const HeaderWithAuth = () => {
  const location = useLocation();
  const [shortcutsVisible, setShortcutsVisible] = useState(false);

  // Keyboard shortcut to open shortcuts modal
  useEffect(() => {
    const handleKeyDown = (event) => {
      // Don't trigger if user is typing in an input
      if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') {
        return;
      }

      // Press ? to show shortcuts
      if (event.key === '?' && !event.shiftKey && !event.ctrlKey && !event.metaKey) {
        event.preventDefault();
        setShortcutsVisible(true);
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => {
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, []);

  return (
    <Header style={{
      background: '#fff',
      boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 16px'
    }}>
      <Space>
        <Title level={4} style={{ margin: 0, fontSize: '18px' }}>
          {location.pathname === '/' && ' '}
          {location.pathname === '/refill' && 'Quick Refill'}
          {location.pathname === '/summary' && ' '}
          {location.pathname === '/prescriber-overview' && ' '}
          {location.pathname === '/enrollments' && 'Enrollments Management'}
          {location.pathname === '/patients' && 'Patients List'}
          {location.pathname === '/drugs' && 'Drug List'}
          {location.pathname === '/departments' && 'Departments List'}
          {location.pathname === '/reports' && 'Reports'}
        </Title>
      </Space>

      <Space>
        <div style={{ color: '#666', fontSize: '12px', marginRight: '16px' }}>
          <span style={{ '@media (min-width: 768px)': { display: 'inline' } }}>
            QDMS - Hospital Segamat
          </span>
        </div>
        <Tooltip title="Keyboard Shortcuts (Press ?)">
          <Button
            type="text"
            icon={<QuestionCircleOutlined />}
            onClick={() => setShortcutsVisible(true)}
            style={{ marginRight: '8px' }}
          />
        </Tooltip>
        <UserProfile />
      </Space>

      <KeyboardShortcutsModal
        visible={shortcutsVisible}
        onClose={() => setShortcutsVisible(false)}
      />
    </Header>
  );
};

export default HeaderWithAuth;
