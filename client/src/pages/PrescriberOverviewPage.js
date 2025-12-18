import React, { useState, useEffect } from 'react';
import {
  Card,
  Typography,
  Row,
  Col,
  Statistic,
  Progress,
  Tag,
  Space,
  Spin,
  Modal,
  List,
  Input,
  Select,
  Button,
  Divider,
  Empty,
  Alert
} from 'antd';
import {
  MedicineBoxOutlined,
  UserOutlined,
  BankOutlined,
  SearchOutlined,
  ReloadOutlined,
  CheckCircleOutlined,
  WarningOutlined,
  CloseCircleOutlined
} from '@ant-design/icons';
import { drugsAPI, departmentsAPI, enrollmentsAPI } from '../services/api';
import { useDebounce } from '../hooks/useDebounce';
import dayjs from 'dayjs';
import './MediaWidth.css';
import './PrescriberOverviewPage.css';
import '../components/EnhancedDrugCard.css';

const { Title, Text } = Typography;
const { Option } = Select;

const PrescriberOverviewPage = () => {
  const [departments, setDepartments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchText, setSearchText] = useState('');
  const debouncedSearchText = useDebounce(searchText, 300);
  const [selectedDepartment, setSelectedDepartment] = useState('all');
  const [allDepartments, setAllDepartments] = useState([]);
  const [drugModalVisible, setDrugModalVisible] = useState(false);
  const [selectedDrug, setSelectedDrug] = useState(null);
  const [drugEnrollments, setDrugEnrollments] = useState([]);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);
      const [drugsResponse, enrollmentsResponse, allDepartmentsResponse] = await Promise.all([
        drugsAPI.getAll(),
        enrollmentsAPI.getAll(),
        departmentsAPI.getAll()
      ]);

      setAllDepartments(allDepartmentsResponse.data);

      const drugs = drugsResponse.data;
      const enrollments = enrollmentsResponse.data;

      // Create a map of drug_id to department_id for quick lookup
      const drugToDepartmentMap = {};
      drugs.forEach(drug => {
        drugToDepartmentMap[drug.id] = drug.department_id;
      });

      // Count unique active patients per department
      const departmentActivePatientsMap = {};
      enrollments.forEach(enrollment => {
        // Only count active enrollments
        if (enrollment.is_active && enrollment.drug_id && drugToDepartmentMap[enrollment.drug_id]) {
          const deptId = drugToDepartmentMap[enrollment.drug_id];
          if (!departmentActivePatientsMap[deptId]) {
            departmentActivePatientsMap[deptId] = new Set();
          }
          // Use patient_id to ensure uniqueness
          if (enrollment.patient_id) {
            departmentActivePatientsMap[deptId].add(enrollment.patient_id);
          }
        }
      });

      // Group drugs by department
      const departmentMap = {};
      drugs.forEach(drug => {
        if (!departmentMap[drug.department_id]) {
          departmentMap[drug.department_id] = {
            id: drug.department_id,
            name: drug.department_name,
            drugs: [],
            totalQuota: 0,
            totalActivePatients: 0
          };
        }
        departmentMap[drug.department_id].drugs.push(drug);
        departmentMap[drug.department_id].totalQuota += drug.quota_number || 0;
      });

      // Set the unique active patient count for each department
      Object.keys(departmentMap).forEach(deptId => {
        departmentMap[deptId].totalActivePatients = departmentActivePatientsMap[deptId]
          ? departmentActivePatientsMap[deptId].size
          : 0;
      });

      const departmentList = Object.values(departmentMap);
      setDepartments(departmentList);
    } catch (error) {
      const errorMessage = error.response?.data?.message || error.message || 'Failed to fetch data. Please try again.';
      setError(errorMessage);
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const getQuotaColor = (utilization) => {
    if (utilization >= 90) return '#ff4d4f';
    if (utilization >= 75) return '#faad14';
    return '#52c41a';
  };

  const getDepartmentColor = (deptName) => {
    if (!deptName) return '#D3D3D3'; // Default color (light gray)

    // Check based on the start of the string
    if (deptName.startsWith('01')) return '#87CEEB'; // Medical (Sky Blue)
    if (deptName.startsWith('02')) return '#2ecc71'; // Surgical (Emerald Green)
    if (deptName.startsWith('03')) return '#DAA520'; // Ophthalmology (Goldenrod)
    if (deptName.startsWith('04')) return '#E6E6FA'; // Orthopaedic (Lavender)
    if (deptName.startsWith('05')) return '#FF69B4'; // O&G (Hot Pink)
    if (deptName.startsWith('06')) return '#2F54EB'; // Psychiatric (Geek Blue)
    if (deptName.startsWith('07')) return '#40E0D0'; // ENT (Turquoise)
    if (deptName.startsWith('08')) return '#A3C7E8'; // Paediatric (Baby Blue)
    if (deptName.startsWith('09')) return '#32CD32'; // Nephrology (Lime Green)
    if (deptName.startsWith('10')) return '#FF7F50'; // Rehab Clinic (Coral Orange)

    return '#D3D3D3'; // Default fallback color
  };

  const handleDepartmentChange = (value) => {
    setSelectedDepartment(value);
    setSearchText(''); // Clear the search text
  };

  const getDrugQuotaColor = (active, quota) => {
    const utilization = quota > 0 ? (active / quota) * 100 : 0;
    if (utilization >= 100) return '#ff4d4f';
    if (utilization >= 80) return '#faad14';
    if (utilization >= 50) return '#1890ff';
    return '#52c41a';
  };

  const getUtilizationColor = (active, quota) => {
    const percentage = quota > 0 ? (active / quota) * 100 : 0;
    if (percentage >= 100) return '#ff4d4f';
    if (percentage >= 80) return '#faad14';
    if (percentage >= 50) return '#1890ff';
    return '#52c41a';
  };

  const getStatusIcon = (utilization) => {
    if (utilization >= 90) return <CloseCircleOutlined />;
    if (utilization >= 70) return <WarningOutlined />;
    return <CheckCircleOutlined />;
  };

  const handleRefresh = async () => {
    setSearchText('');
    setSelectedDepartment('all');
    await fetchData();
  };

  // Filter departments and drugs based on search text (using debounced value)
  const filteredDepartments = departments
    .filter(dept => {
      // 1. Apply the department dropdown filter first
      if (selectedDepartment !== 'all' && dept.id !== selectedDepartment) {
        return false;
      }
      return true;
    })
    .filter(dept => {
      // 2. Then, apply the search text filter on the remaining departments
      if (!debouncedSearchText) return true;
      const searchLower = debouncedSearchText.toLowerCase();

      // If a department is specifically selected, we only need to search within its drugs
      if (selectedDepartment !== 'all') {
        return dept.drugs.some(drug => drug.name.toLowerCase().includes(searchLower));
      }

      // Otherwise, search both department name and drug names
      if (dept.name.toLowerCase().includes(searchLower)) return true;
      return dept.drugs.some(drug => drug.name.toLowerCase().includes(searchLower));
    })
    .map(dept => ({
      ...dept,
      drugs: debouncedSearchText
        ? dept.drugs.filter(drug => drug.name.toLowerCase().includes(debouncedSearchText.toLowerCase()))
        : dept.drugs,
    }))
    .filter(dept => dept.drugs.length > 0);

  const handleDrugClick = async (drug) => {
    try {
      setSelectedDrug(drug);
      setDrugModalVisible(true);

      // Fetch enrollments for this drug
      const response = await enrollmentsAPI.getAll({
        drug_id: drug.id,
        active_only: 'true'
      });
      setDrugEnrollments(response.data);
    } catch (error) {
      console.error('Error fetching drug enrollments:', error);
      setDrugEnrollments([]);
    }
  };

  if (loading) {
    return (
      <div className="page-container" style={{ background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', minHeight: '100vh' }}>
        <Card style={{ background: '#ffffff', boxShadow: '0 20px 60px rgba(0, 0, 0, 0.3)' }}>
          <div style={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            minHeight: '400px'
          }}>
            <Spin size="large" />
          </div>
        </Card>
      </div>
    );
  }

  return (
    <div className="page-container" style={{ background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', minHeight: '100vh' }}>
      <Card style={{ background: '#ffffff', boxShadow: '0 20px 60px rgba(0, 0, 0, 0.3)' }}>
        {/* Header Section with Contrast */}
        <div style={{
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          margin: '-24px -24px 24px -24px',
          padding: '24px',
          borderRadius: '8px 8px 0 0',
          color: '#ffffff',
          position: 'relative',
          overflow: 'hidden'
        }}>
          <div style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: 'radial-gradient(circle at 20% 50%, rgba(255, 255, 255, 0.1) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(255, 255, 255, 0.1) 0%, transparent 50%), radial-gradient(circle at 40% 20%, rgba(255, 255, 255, 0.05) 0%, transparent 50%)'
          }} />
          <Row justify="center" align="middle" style={{ position: 'relative', zIndex: 1 }}>
            <Col xs={24} style={{ textAlign: 'center' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '12px', marginBottom: '8px' }}>
                <div className="header-icon" style={{
                  background: 'rgba(255, 255, 255, 0.2)',
                  borderRadius: '8px',
                  padding: '8px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <BankOutlined style={{ fontSize: '28px', color: '#ffffff' }} />
                </div>
                <Title level={2} style={{
                  margin: 0,
                  color: '#ffffff',
                  fontWeight: '700',
                  textShadow: '0 2px 4px rgba(0, 0, 0, 0.2)'
                }}>
                  Departmental Overview
                </Title>
              </div>
              <Text style={{
                color: 'rgba(255, 255, 255, 0.9)',
                fontSize: '14px',
                display: 'block'
              }}>
                Summary of quota drug utilization by department <br />
                Quota Drug Management System <br />
                Jabatan Farmasi Hospital Segamat
              </Text>
            </Col>
          </Row>
        </div>

        {/* Search and Filter Bar */}
        <div style={{ marginBottom: '16px' }}>
          <Row gutter={[12, 12]}>
            <Col xs={24} sm={8}>
              <Select
                placeholder="Filter by department"
                value={selectedDepartment}
                onChange={handleDepartmentChange}
                style={{ width: '100%' }}
                size="medium"
              >
                <Option value="all">All Departments</Option>
                {allDepartments.map(dept => (
                  <Option key={dept.id} value={dept.id}>
                    {dept.name.includes(' - ') ? dept.name.split(' - ')[1] : dept.name}
                  </Option>
                ))}
              </Select>
            </Col>
            <Col xs={20} sm={14}>
              <Input
                placeholder="Search drugs by name or department..."
                value={searchText}
                onChange={(e) => setSearchText(e.target.value)}
                className="search-bar search-bar-md"
                style={{ width: '100%' }}
                prefix={<SearchOutlined />}
                autoComplete="off"
                size="small"
              />
            </Col>
            <Col xs={4} sm={2}>
              <Button
                icon={<ReloadOutlined />}
                onClick={handleRefresh}
                loading={loading}
                title="Refresh"
                style={{ width: '40px', height: '40px', padding: 0 }}
              />
            </Col>
          </Row>
        </div>

        {/* Error Alert */}
        {error && !loading && (
          <Alert
            message="Error Loading Data"
            description={error}
            type="error"
            showIcon
            action={
              <Button size="small" onClick={fetchData}>
                Retry
              </Button>
            }
            closable
            onClose={() => setError(null)}
            style={{ marginBottom: '16px' }}
          />
        )}

        {/* Department Cards */}
        {loading ? (
          <Row gutter={[16, 16]}>
            {[1, 2, 3, 4, 5, 6].map(i => (
              <Col xs={24} sm={12} lg={8} key={i}>
                <Card>
                  <div style={{ padding: '20px' }}>
                    <div style={{ marginBottom: '16px' }}>
                      <div style={{ height: '24px', background: '#f0f0f0', borderRadius: '4px', marginBottom: '8px' }} />
                      <div style={{ height: '16px', background: '#f0f0f0', borderRadius: '4px', width: '60%' }} />
                    </div>
                    <div style={{ height: '100px', background: '#f0f0f0', borderRadius: '4px', marginBottom: '16px' }} />
                    <div style={{ height: '8px', background: '#f0f0f0', borderRadius: '4px', marginBottom: '8px' }} />
                  </div>
                </Card>
              </Col>
            ))}
          </Row>
        ) : (
          <>
            {filteredDepartments.length > 0 ? (
              <Row gutter={[16, 16]}>
                {filteredDepartments.map(department => {
                  const deptUtilization = department.totalQuota > 0
                    ? Math.round((department.totalActivePatients / department.totalQuota) * 100)
                    : 0;
                  const deptColor = getDepartmentColor(department.name);
                  const deptShortName = department.name.includes(' - ')
                    ? department.name.split(' - ')[1]
                    : department.name;

                  return (
                    <Col xs={24} sm={12} lg={8} key={department.id}>
                      <Card
                        hoverable
                        className="enhanced-drug-card"
                        style={{
                          borderRadius: '12px',
                          overflow: 'hidden',
                          border: '1px solid #D3D3D3',
                          transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                          height: '100%',
                          background: '#ffffff',
                          '--dept-color': deptColor
                        }}
                        bodyStyle={{ padding: '20px' }}
                      >
                        {/* Department Header */}
                        <div style={{
                          borderLeft: `8px solid ${deptColor}`,
                          paddingLeft: '16px',
                          marginBottom: '20px'
                        }}>
                          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                            <div style={{ flex: 1 }}>
                              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
                                <BankOutlined style={{ fontSize: '20px', color: deptColor }} />
                                <h3 style={{ margin: 0, fontSize: '18px', fontWeight: '600' }}>
                                  {deptShortName}
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
                                {department.drugs.length} drug{department.drugs.length !== 1 ? 's' : ''}
                              </Tag>
                            </div>

                          </div>
                        </div>

                        {/* Department Statistics */}
                        <div style={{ marginBottom: '20px' }}>
                          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px' }}>
                            <Space>
                              <UserOutlined style={{ color: '#666' }} />
                              <span style={{ fontWeight: '500', color: '#333' }}>
                                {department.totalActivePatients} / {department.totalQuota}
                              </span>
                              <span style={{ fontSize: '12px', color: '#999' }}>patients</span>
                            </Space>
                            <Tag
                              color={department.totalQuota - department.totalActivePatients > 0 ? 'green' : 'red'}
                              style={{ borderRadius: '6px' }}
                            >
                              {department.totalQuota - department.totalActivePatients} available
                            </Tag>
                          </div>

                          <Progress
                            percent={deptUtilization}
                            strokeColor={{
                              '0%': getUtilizationColor(department.totalActivePatients, department.totalQuota),
                              '100%': getUtilizationColor(department.totalActivePatients, department.totalQuota),
                            }}
                            trailColor="#f0f0f0"
                            strokeWidth={8}
                            showInfo={false}
                            style={{ marginBottom: '12px' }}
                          />

                          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                              <Progress
                                type="circle"
                                percent={deptUtilization}
                                strokeColor={getUtilizationColor(department.totalActivePatients, department.totalQuota)}
                                width={60}
                                format={() => `${deptUtilization}%`}
                                strokeWidth={8}
                              />
                              <div>
                                <div style={{ fontSize: '14px', color: '#666' }}>Utilization</div>
                                <div style={{ fontSize: '20px', fontWeight: '700', color: getUtilizationColor(department.totalActivePatients, department.totalQuota) }}>
                                  {deptUtilization}%
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>

                        <Divider style={{ margin: '16px 0' }} />

                        {/* Drug List */}
                        <div style={{ maxHeight: '400px', overflowY: 'auto' }}>
                          <Text strong style={{ fontSize: '14px', marginBottom: '12px', display: 'block' }}>
                            Drugs ({department.drugs.length}):
                          </Text>
                          {department.drugs.map(drug => {
                            const utilization = drug.quota_number > 0
                              ? Math.round((drug.current_active_patients / drug.quota_number) * 100)
                              : 0;
                            const availableSlots = drug.quota_number - drug.current_active_patients;

                            return (
                              <div
                                key={drug.id}
                                onClick={() => handleDrugClick(drug)}
                                className="drug-item-hover"
                                style={{
                                  padding: '12px',
                                  margin: '8px 0',
                                  background: '#f8f9fa',
                                  borderRadius: '8px',
                                  border: `1px solid ${getDrugQuotaColor(drug.current_active_patients, drug.quota_number)}80`,
                                  cursor: 'pointer'
                                }}
                              >
                                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                    <MedicineBoxOutlined style={{ color: getDrugQuotaColor(drug.current_active_patients, drug.quota_number) }} />
                                    <Text strong style={{ fontSize: '14px' }}>{drug.name}</Text>
                                  </div>
                                  <Tag
                                    color={getDrugQuotaColor(drug.current_active_patients, drug.quota_number)}
                                    style={{ fontSize: '12px', padding: '2px 8px' }}
                                  >
                                    {drug.current_active_patients}/{drug.quota_number}
                                  </Tag>
                                </div>
                                <Progress
                                  percent={utilization}
                                  strokeColor={getDrugQuotaColor(drug.current_active_patients, drug.quota_number)}
                                  size="small"
                                  showInfo={false}
                                  style={{ marginBottom: '6px' }}
                                />
                                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: '#666' }}>
                                  <span>Available: {availableSlots}</span>
                                  <span>{utilization}% utilized</span>
                                </div>
                              </div>
                            );
                          })}
                        </div>
                      </Card>
                    </Col>
                  );
                })}
              </Row>
            ) : (
              <Empty
                image={Empty.PRESENTED_IMAGE_SIMPLE}
                description={
                  <span>
                    {debouncedSearchText || selectedDepartment !== 'all'
                      ? `No departments or drugs match your search${debouncedSearchText ? ` for "${debouncedSearchText}"` : ''}`
                      : 'No departments found'}
                  </span>
                }
              >
                {debouncedSearchText || selectedDepartment !== 'all' ? (
                  <Button type="primary" onClick={handleRefresh}>
                    Clear Filters
                  </Button>
                ) : null}
              </Empty>
            )}
          </>
        )}
      </Card>



      {/* Drug Details Modal */}
      <Modal
        title={
          <div style={{ borderLeft: `8px solid ${getDepartmentColor(selectedDrug?.department_name)}`, paddingLeft: '16px', lineHeight: '1.4', borderRadius: '8px' }}>
            <Title level={4} style={{ margin: 0, color: 'var(--text-on-light-bg)' }}>
              {selectedDrug?.name} <Space />
              <Tag
                color={getDepartmentColor(selectedDrug?.department_name)}
                style={{ marginLeft: '16px', fontWeight: '500' }}
              >
                {selectedDrug?.department_name.includes(' - ') ? selectedDrug?.department_name.split(' - ')[1] : selectedDrug?.department_name || 'Unknown Department'}
              </Tag>
            </Title>
            <Text type="secondary" style={{ fontSize: '12px' }}>
              Quota Details
            </Text>
          </div>
        }
        open={drugModalVisible}
        onCancel={() => setDrugModalVisible(false)}
        footer={null}
        width="95%"
        style={{ maxWidth: '768px' }}
        centered
      >
        {selectedDrug && (
          <div>
            {/* Drug Information */}
            <Card size="small" style={{ marginBottom: '16px' }}>
              <Row gutter={16}>
                <Col xs={24} sm={8} style={{ textAlign: 'center' }}>
                  <Statistic
                    title="Total Quota"
                    value={selectedDrug.quota_number}
                    prefix={<MedicineBoxOutlined />}
                    valueStyle={{ color: '#1890ff' }}
                  />
                </Col>
                <Col xs={24} sm={8} style={{ textAlign: 'center' }}>
                  <Statistic
                    title="Active Patients"
                    value={selectedDrug.current_active_patients}
                    prefix={<UserOutlined />}
                    valueStyle={{ color: '#52c41a' }}
                  />
                </Col>
                <Col xs={24} sm={8} style={{ textAlign: 'center' }}>
                  <Statistic
                    title="Available Slots"
                    value={selectedDrug.quota_number - selectedDrug.current_active_patients}
                    valueStyle={{ color: '#faad14' }}
                  />
                </Col>
              </Row>
              <div style={{ marginTop: '16px' }}>
                <Text strong>Quota Utilization: </Text>
                <Progress
                  percent={
                    selectedDrug.quota_number > 0
                      ? Math.round(
                        (selectedDrug.current_active_patients /
                          selectedDrug.quota_number) * 100
                      )
                      : 0
                  }
                  strokeColor={getDrugQuotaColor(
                    selectedDrug.current_active_patients,
                    selectedDrug.quota_number
                  )}
                  format={(percent) => (
                    <span style={{ color: getDrugQuotaColor(selectedDrug.current_active_patients, selectedDrug.quota_number) }}>
                      {percent}%
                    </span>
                  )}
                />
                <Text strong>Remarks: </Text>
                <Text>{selectedDrug.remarks || '-'}</Text>
              </div>
            </Card>

            {/* Active Patients List */}
            <Card title="Active Patients" size="small">
              {drugEnrollments.length > 0 ? (
                <div style={{ maxHeight: '400px', overflowY: 'auto' }}>
                  <List
                    dataSource={drugEnrollments.sort((a, b) => a.patient_name.localeCompare(b.patient_name))}
                    renderItem={(enrollment) => (
                      <List.Item style={{ borderBottom: '1px solid #f0f0f0', padding: '12px 0' }}>
                        <Space>
                          <UserOutlined style={{ color: '#1890ff' }} />
                          <Text style={{ fontSize: '14px' }}>{enrollment.patient_name}</Text>
                        </Space>
                      </List.Item>
                    )}
                  />
                </div>
              ) : (
                <div style={{ textAlign: 'center', padding: '20px', color: '#999' }}>
                  No active patients enrolled for this drug
                </div>
              )}
            </Card>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default PrescriberOverviewPage;
