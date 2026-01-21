import React from 'react';
import { Card, Progress, Tag, Space } from 'antd';
import {
  MedicineBoxOutlined,
  UserOutlined
} from '@ant-design/icons';
import './EnhancedDrugCard.css';

/**
 * Enhanced Drug Card Component
 * A modern, visually appealing card for displaying drug information
 * with quota utilization, department badges, and interactive elements.
 * 
 * @param {Object} drug - Drug data object
 * @param {Function} onClick - Click handler for the card
 * @param {Function} onEnroll - Handler for enrolling a patient
 */
const EnhancedDrugCard = ({ drug, onClick, onEnroll }) => {
  const {
    name,
    department_name,
    quota_number,
    current_active_patients,
    price,
    remarks
  } = drug;

  // Calculate utilization percentage
  const utilization = quota_number > 0
    ? Math.round((current_active_patients / quota_number) * 100)
    : 0;

  // Determine status color based on utilization
  const getStatusColor = () => {
    if (utilization >= 90) return '#ef4444'; // Red - Critical
    if (utilization >= 70) return '#f59e0b'; // Orange - Warning
    if (utilization >= 50) return '#3b82f6'; // Blue - Moderate
    return '#10b981'; // Green - Good
  };

  // Calculate available slots
  const availableSlots = quota_number - current_active_patients;

  // Extract department short name (after " - ")
  const deptShortName = department_name.includes(' - ')
    ? department_name.split(' - ')[1]
    : department_name;

  return (
    <Card
      className="enhanced-drug-card"
      hoverable
      onClick={onClick}
      style={{
        borderRadius: '12px',
        overflow: 'hidden',
        border: `1px solid ${getStatusColor()}20`,
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
      }}
      bodyStyle={{ padding: '20px' }}
    >
      {/* Header Section */}
      <div className="card-header">
        <Space direction="vertical" size={4} style={{ width: '100%' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
                <MedicineBoxOutlined style={{ fontSize: '20px', color: getStatusColor() }} />
                <h3 style={{ margin: 0, fontSize: '18px', fontWeight: '600' }}>
                  {name}
                </h3>
              </div>
              <Tag
                color="blue"
                style={{
                  borderRadius: '6px',
                  padding: '2px 12px',
                  fontSize: '12px'
                }}
              >
                {deptShortName}
              </Tag>
            </div>
          </div>
        </Space>
      </div>

      {/* Quota Visualization Section */}
      <div className="quota-section" style={{ marginTop: '20px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px' }}>
          <Space>
            <UserOutlined style={{ color: '#666' }} />
            <span style={{ fontWeight: '500', color: '#333' }}>
              {current_active_patients} / {quota_number}
            </span>
            <span style={{ fontSize: '12px', color: '#999' }}>patients</span>
          </Space>
          <Tag
            color={availableSlots > 0 ? 'green' : 'red'}
            style={{ borderRadius: '6px' }}
          >
            {availableSlots} available
          </Tag>
        </div>

        {/* Progress Bar */}
        <Progress
          percent={utilization}
          strokeColor={{
            '0%': getStatusColor(),
            '100%': getStatusColor(),
          }}
          trailColor="#f0f0f0"
          strokeWidth={8}
          showInfo={false}
          style={{ marginBottom: '12px' }}
        />

        {/* Circular Progress Indicator */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <Progress
              type="circle"
              percent={utilization}
              strokeColor={getStatusColor()}
              width={60}
              format={() => `${utilization}%`}
              strokeWidth={8}
            />
            <div>
              <div style={{ fontSize: '14px', color: '#666' }}>Utilization</div>
              <div style={{ fontSize: '20px', fontWeight: '700', color: getStatusColor() }}>
                {utilization}%
              </div>
            </div>
          </div>

          {/* Price Display */}
          {price && (
            <div style={{ textAlign: 'right' }}>
              <div style={{ fontSize: '12px', color: '#999' }}>Price/SKU</div>
              <div style={{ fontSize: '16px', fontWeight: '600', color: '#333' }}>
                RM {Number(price).toFixed(2)}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Remarks Section */}
      {remarks && (
        <div style={{
          marginTop: '16px',
          padding: '12px',
          background: '#f8f9fa',
          borderRadius: '8px',
          fontSize: '13px',
          color: '#666'
        }}>
          <strong>Note:</strong> {remarks}
        </div>
      )}

      {/* Action Buttons (shown on hover) */}
      <div className="card-actions" style={{ marginTop: '16px' }}>
        <button
          className="enroll-button"
          onClick={(e) => {
            e.stopPropagation();
            onEnroll(drug);
          }}
          disabled={availableSlots <= 0}
          style={{
            width: '100%',
            padding: '10px',
            background: availableSlots > 0 ? getStatusColor() : '#d9d9d9',
            color: 'white',
            border: 'none',
            borderRadius: '8px',
            fontSize: '14px',
            fontWeight: '600',
            cursor: availableSlots > 0 ? 'pointer' : 'not-allowed',
            transition: 'all 0.2s',
          }}
        >
          {availableSlots > 0 ? 'Enroll Patient' : 'Quota Full'}
        </button>
      </div>
    </Card>
  );
};

export default EnhancedDrugCard;
