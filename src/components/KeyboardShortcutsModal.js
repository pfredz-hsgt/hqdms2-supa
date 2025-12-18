import React from 'react';
import { Modal, Typography, Space, Divider, Tag } from 'antd';
import { QuestionCircleOutlined } from '@ant-design/icons';

const { Title, Text, Paragraph } = Typography;

const KeyboardShortcutsModal = ({ visible, onClose }) => {
  const shortcuts = [
    {
      category: 'General',
      items: [
        { keys: ['?'], description: 'Show keyboard shortcuts' },
        { keys: ['Esc'], description: 'Close modals/dialogs' },
      ]
    },
    {
      category: 'Forms',
      items: [
        { keys: ['Ctrl', 'Enter'], description: 'Submit form (when modal is open)' },
        { keys: ['Enter'], description: 'Submit form or move to next field' },
        { keys: ['Esc'], description: 'Cancel and close form' },
      ]
    },
    {
      category: 'Navigation',
      items: [
        { keys: ['/'], description: 'Focus search bar (if available)' },
        { keys: ['Ctrl', 'K'], description: 'Quick search (if implemented)' },
      ]
    },
    {
      category: 'Drug List Page',
      items: [
        { keys: ['Click row'], description: 'View drug details' },
        { keys: ['Type in search'], description: 'Search drugs (debounced)' },
      ]
    },
    {
      category: 'Refill Update Page',
      items: [
        { keys: ['Type anywhere'], description: 'Start typing to search patients' },
        { keys: ['Esc'], description: 'Clear search' },
      ]
    },
  ];

  const renderKeys = (keys) => {
    return (
      <Space size={4}>
        {keys.map((key, index) => (
          <React.Fragment key={index}>
            <Tag
              style={{
                margin: 0,
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '2px 8px',
                background: '#f5f5f5',
                border: '1px solid #d9d9d9',
                borderRadius: '4px'
              }}
            >
              {key}
            </Tag>
            {index < keys.length - 1 && (
              <Text type="secondary" style={{ margin: '0 4px' }}>+</Text>
            )}
          </React.Fragment>
        ))}
      </Space>
    );
  };

  return (
    <Modal
      title={
        <Space>
          <QuestionCircleOutlined />
          <span>Keyboard Shortcuts</span>
        </Space>
      }
      open={visible}
      onCancel={onClose}
      footer={null}
      width={600}
      centered
    >
      <div style={{ maxHeight: '60vh', overflowY: 'auto' }}>
        {shortcuts.map((category, categoryIndex) => (
          <div key={categoryIndex} style={{ marginBottom: '24px' }}>
            <Title level={5} style={{ marginBottom: '12px', color: '#1890ff' }}>
              {category.category}
            </Title>
            <Space direction="vertical" size="middle" style={{ width: '100%' }}>
              {category.items.map((item, itemIndex) => (
                <div
                  key={itemIndex}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '8px 0',
                    borderBottom: itemIndex < category.items.length - 1 ? '1px solid #f0f0f0' : 'none'
                  }}
                >
                  <div style={{ flex: 1 }}>
                    {renderKeys(item.keys)}
                  </div>
                  <Text type="secondary" style={{ marginLeft: '16px', textAlign: 'right' }}>
                    {item.description}
                  </Text>
                </div>
              ))}
            </Space>
            {categoryIndex < shortcuts.length - 1 && (
              <Divider style={{ margin: '16px 0' }} />
            )}
          </div>
        ))}
      </div>
      <Divider />
      <Paragraph type="secondary" style={{ textAlign: 'center', marginBottom: 0, fontSize: '12px' }}>
        Press <Tag style={{ fontFamily: 'monospace' }}>Esc</Tag> or click outside to close
      </Paragraph>
    </Modal>
  );
};

export default KeyboardShortcutsModal;



