import React, { useState, useEffect, useRef } from 'react';
import {
  Card,
  Table,
  List,
  Avatar,
  Button,
  Dropdown,
  Typography,
  Space,
  Modal,
  Form,
  Input,
  InputNumber,
  Select,
  message,
  Popconfirm,
  Tag,
  Tooltip,
  Progress,
  Row,
  Col,
  Statistic,
  Divider,
  DatePicker,
  Switch,
  Segmented,
  Empty,
  Skeleton,
  Alert
} from 'antd';
import {
  PlusOutlined,
  EditOutlined,
  CheckOutlined,
  CloseOutlined,
  DeleteOutlined,
  MedicineBoxOutlined,
  DollarOutlined,
  UserOutlined,
  UserAddOutlined,
  ReloadOutlined,
  MoreOutlined,
  SearchOutlined,
  TableOutlined,
  AppstoreOutlined,
  DownloadOutlined
} from '@ant-design/icons';
import { drugsAPI, departmentsAPI, patientsAPI, enrollmentsAPI } from '../services/api';
import CustomDateInput from '../components/CustomDateInput';
import CostPerDayInput from '../components/CostPerDayInput';
import EnhancedDrugCard from '../components/EnhancedDrugCard';
import { useDebounce } from '../hooks/useDebounce';
import dayjs from 'dayjs';
import './MediaWidth.css';
import './DrugListPage.css';
import { useSettings } from '../contexts/SettingsContext';
import * as XLSX from 'xlsx';
import { FaFileExcel } from 'react-icons/fa';

const { Title, Text } = Typography;
const { Option } = Select;
const { Search } = Input;

const DrugListPage = () => {
  const { settings, loading: settingsLoading } = useSettings();
  const [drugs, setDrugs] = useState([]);
  const [departments, setDepartments] = useState([]);
  const [patients, setPatients] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingDrug, setEditingDrug] = useState(null);
  const [form] = Form.useForm();
  const [searchText, setSearchText] = useState('');
  const debouncedSearchText = useDebounce(searchText, 300);
  const [selectedDepartment, setSelectedDepartment] = useState('all');
  const [deptModalVisible, setDeptModalVisible] = useState(false);
  const [deptForm] = Form.useForm();
  const [enrollModalVisible, setEnrollModalVisible] = useState(false);
  const [enrollForm] = Form.useForm();
  const [selectedDrug, setSelectedDrug] = useState(null);
  const [duration, setDuration] = useState(0);
  const [drugDetailsModalVisible, setDrugDetailsModalVisible] = useState(false);
  const [drugEnrollments, setDrugEnrollments] = useState([]);
  const [inactiveEnrollments, setInactiveEnrollments] = useState([]);
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editingEnrollment, setEditingEnrollment] = useState(null);
  const [editForm] = Form.useForm();
  const [patientSearchText, setPatientSearchText] = useState('');
  const [showCreatePatient, setShowCreatePatient] = useState(false);
  const [patientForm] = Form.useForm();
  const [filteredDrugs, setFilteredDrugs] = useState([]);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 10, // Your defaultPageSize
  });
  const [viewMode, setViewMode] = useState('table'); // 'table' or 'card'
  const patientSelectRef = useRef(null);


  useEffect(() => {
    fetchData();
  }, []);

  const handleRefresh = async () => {
    setSearchText('');
    setSelectedDepartment('all');
    setPagination(prevPagination => ({
      ...prevPagination,
      current: 1,
    }));
    await fetchData();
  };

  const handleDepartmentChange = (value) => {
    setSelectedDepartment(value);
    setSearchText('');
  };
  // Update filtered drugs when drugs, debouncedSearchText, or selectedDepartment changes
  useEffect(() => {
    const filtered = drugs.filter(drug => {
      // Text search filter (using debounced value)
      if (debouncedSearchText) {
        const searchLower = debouncedSearchText.toLowerCase();
        const matchesSearch = (
          (drug.name ?? '').toLowerCase().includes(searchLower) ||
          (drug.department_name ?? '').toLowerCase().includes(searchLower)
        );
        if (!matchesSearch) return false;
      }

      // Department filter
      if (selectedDepartment !== 'all') {
        return drug.department_id === selectedDepartment;
      }

      return true;
    });
    setFilteredDrugs(filtered);
  }, [drugs, debouncedSearchText, selectedDepartment]);

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (event) => {
      // Ctrl+Enter to submit forms when modals are open
      if (enrollModalVisible && event.ctrlKey && event.key === 'Enter') {
        event.preventDefault();
        enrollForm.submit();
      }
      if (editModalVisible && event.ctrlKey && event.key === 'Enter') {
        event.preventDefault();
        editForm.submit();
      }
      // Escape to close modals
      if (enrollModalVisible && event.key === 'Escape') {
        setEnrollModalVisible(false);
      }
      if (editModalVisible && event.key === 'Escape') {
        setEditModalVisible(false);
      }
      if (showCreatePatient && event.key === 'Escape') {
        setShowCreatePatient(false);
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => {
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [enrollModalVisible, editModalVisible, showCreatePatient, enrollForm, editForm]);

  const fetchData = async () => {
    setLoading(true);
    setError(null);
    try {
      const [drugsResponse, deptResponse, patientsResponse] = await Promise.all([
        drugsAPI.getAll(),
        departmentsAPI.getAll(),
        patientsAPI.getAll()
      ]);
      setDrugs(drugsResponse.data);
      setDepartments(deptResponse.data);
      setPatients(patientsResponse.data);
    } catch (error) {
      const errorMessage = error.response?.data?.message || error.message || 'Failed to fetch data. Please try again.';
      setError(errorMessage);
      message.error(errorMessage);
      console.error('Fetch error:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleTableChange = (newPagination) => {
    setPagination({
      ...pagination,
      current: newPagination.current,
      pageSize: newPagination.pageSize,
    });
  };

  const handleAdd = () => {
    setEditingDrug(null);
    form.resetFields();
    setModalVisible(true);
  };

  const handleEdit = (drug) => {
    setEditingDrug(drug);
    form.setFieldsValue(drug);
    setModalVisible(true);
  };


  const handleDelete = async (id) => {
    try {
      await drugsAPI.delete(id);
      message.success('Drug deleted successfully');
      fetchData();
    } catch (error) {
      message.error('Error deleting drug');
      console.error('Delete error:', error);
    }
  };

  const handleSubmit = async (values) => {
    try {
      let updatedDrugData = null;

      if (editingDrug) {
        const response = await drugsAPI.update(editingDrug.id, values);
        updatedDrugData = response.data;
        message.success('Drug updated successfully');
      } else {
        const response = await drugsAPI.create(values);
        updatedDrugData = response.data;
        message.success('Drug created successfully');
      }
      if (updatedDrugData) {
        const dept = departments.find(d => d.id === updatedDrugData.department_id);
        updatedDrugData.department_name = dept ? dept.name : 'Unknown';
      }

      setModalVisible(false);
      form.resetFields();

      if (selectedDrug && updatedDrugData && selectedDrug.id === updatedDrugData.id) {
        setSelectedDrug(updatedDrugData);
        console.log("Updated selectedDrug state for details modal.");

        if (drugDetailsModalVisible) {
          await refreshDrugEnrollments();
        }
      }

      fetchData();
    } catch (error) {
      message.error(editingDrug ? 'Error updating drug' : 'Error creating drug');
      console.error('Submit error:', error);
    }
  };


  const handleCreateDepartment = async (values) => {
    try {
      const response = await departmentsAPI.create(values);
      setDepartments(prev => [...prev, response.data]);
      setDeptModalVisible(false);
      deptForm.resetFields();
      message.success('Department created successfully');

      // Auto-select the new department in the drug form
      form.setFieldsValue({ department_id: response.data.id });
    } catch (error) {
      message.error('Error creating department');
      console.error('Department creation error:', error);
    }
  };

  const handleEnrollPatient = (drug) => {
    setSelectedDrug(drug);
    enrollForm.resetFields();
    const startDate = dayjs();
    enrollForm.setFieldsValue({
      drug_id: drug.id,
      prescription_start_date: startDate,
      latest_refill_date: startDate,
      cost_per_day: drug.price ? parseFloat(drug.price).toFixed(2) : undefined
    });
    setEnrollModalVisible(true);
  };

  const handleDurationChange = (value) => {
    setDuration(value);
    const startDate = enrollForm.getFieldValue('prescription_start_date');
    if (startDate && value) {
      const endDate = startDate.add(value, 'day');
      enrollForm.setFieldsValue({
        prescription_end_date: endDate
      });
    }
  };

  const handleStartDateChange = (date) => {
    if (date && duration) {
      const endDate = date.add(duration, 'day');
      enrollForm.setFieldsValue({
        prescription_end_date: endDate
      });
    }
  };

  const handleEnrollSubmit = async (values) => {
    try {
      console.log('Enrollment form values:', values);
      console.log('Selected drug:', selectedDrug);

      // Format dates properly
      const enrollmentData = {
        ...values,
        spub: !!values.spub,
        is_active: !!values.is_active,
        prescription_start_date: values.prescription_start_date
          ? values.prescription_start_date.format('YYYY-MM-DD')
          : null,
        prescription_end_date: values.prescription_end_date
          ? values.prescription_end_date.format('YYYY-MM-DD')
          : null,
        latest_refill_date: values.latest_refill_date
          ? values.latest_refill_date.format('YYYY-MM-DD')
          : null,
      };

      console.log('Sending enrollment data:', enrollmentData);

      await enrollmentsAPI.create(enrollmentData);
      message.success('Patient enrolled successfully');
      setEnrollModalVisible(false);
      enrollForm.resetFields();
      setDuration(0);
      fetchData();

      // Refresh drug enrollments in the modal if it's open
      if (drugDetailsModalVisible && selectedDrug) {
        await refreshDrugEnrollments();
      }
    } catch (error) {
      console.error('Enrollment error:', error);

      // Check if it's a duplicate enrollment error
      if (error.error?.includes('already enrolled') ||
        error.error?.includes('duplicate') ||
        error.response?.status === 400) {
        message.error('Patient is already enrolled in this drug (maybe inactive)');
      } else {
        message.error('Error enrolling patient');
      }
    }
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


  const deptColor = getDepartmentColor(selectedDrug?.department_name);
  const handleCreatePatient = async (values) => {
    try {
      const response = await patientsAPI.create(values);
      message.success('Patient created successfully');

      // Refresh patients list
      const patientsResponse = await patientsAPI.getAll();
      setPatients(patientsResponse.data);

      // Set the newly created patient as selected
      enrollForm.setFieldsValue({ patient_id: response.data.id });

      // Close the create patient modal
      setShowCreatePatient(false);
      patientForm.resetFields();
      setPatientSearchText('');
    } catch (error) {
      message.error('Error creating patient');
      console.error('Error creating patient:', error);
    }
  };

  const handleDrugClick = async (drug) => {
    setSelectedDrug(drug);
    setDrugDetailsModalVisible(true);

    try {
      // Fetch both active and inactive enrollments for this specific drug
      const [activeResponse, inactiveResponse] = await Promise.all([
        enrollmentsAPI.getAll({
          drug_id: drug.id,
          active_only: 'true'
        }),
        enrollmentsAPI.getAll({
          drug_id: drug.id,
          active_only: 'false'
        })
      ]);
      setDrugEnrollments(activeResponse.data);
      setInactiveEnrollments(inactiveResponse.data);
    } catch (error) {
      console.error('Error fetching drug enrollments:', error);
      message.error('Error loading drug details');
    }
  };

  const refreshDrugEnrollments = async () => {
    if (selectedDrug) {
      try {
        const [activeResponse, inactiveResponse] = await Promise.all([
          enrollmentsAPI.getAll({
            drug_id: selectedDrug.id,
            active_only: 'true'
          }),
          enrollmentsAPI.getAll({
            drug_id: selectedDrug.id,
            active_only: 'false'
          })
        ]);
        setDrugEnrollments(activeResponse.data);
        setInactiveEnrollments(inactiveResponse.data);

        // Update the selectedDrug with the new active patient count
        setSelectedDrug(prev => ({
          ...prev,
          current_active_patients: activeResponse.data.length
        }));

        console.log('Drug enrollments refreshed - Active:', activeResponse.data.length, 'Inactive:', inactiveResponse.data.length);
      } catch (error) {
        console.error('Error refreshing drug enrollments:', error);
      }
    }
  };

  const handleExportToExcel = () => {
    if (!selectedDrug) {
      message.error('No drug selected');
      return;
    }

    try {
      // Create workbook
      const wb = XLSX.utils.book_new();

      // Sheet 1: Drug Information
      const drugInfo = [
        ['Drug Name', selectedDrug.name],
        ['Department', selectedDrug.department_name],
        ['Quota Number', selectedDrug.quota_number],
        ['Active Patients', selectedDrug.current_active_patients],
        ['Available Slots', selectedDrug.quota_number - selectedDrug.current_active_patients],
        ['Price per Unit (RM)', selectedDrug.price ? Number(selectedDrug.price).toFixed(2) : '0.00'],
        ['Remarks', selectedDrug.remarks || '-'],
        ['Export Date', dayjs().format('DD/MM/YYYY HH:mm:ss')]
      ];

      const drugSheet = XLSX.utils.aoa_to_sheet(drugInfo);
      XLSX.utils.book_append_sheet(wb, drugSheet, 'Drug Information');

      // Sheet 2: Active Patients
      if (drugEnrollments && drugEnrollments.length > 0) {
        const activePatientsData = drugEnrollments.map(enrollment => ({
          'Patient Name': enrollment.patient_name || '-',
          'IC Number': enrollment.ic_number || '-',
          'Dose per Day': enrollment.dose_per_day || '-',
          'Cost per Day (RM)': enrollment.cost_per_day ? parseFloat(enrollment.cost_per_day).toFixed(2) : '-',
          'Start Date': enrollment.prescription_start_date ? dayjs(enrollment.prescription_start_date).format('DD/MM/YYYY') : '-',
          'End Date': enrollment.prescription_end_date ? dayjs(enrollment.prescription_end_date).format('DD/MM/YYYY') : '-',
          'Last Refill Date': enrollment.latest_refill_date ? dayjs(enrollment.latest_refill_date).format('DD/MM/YYYY') : '-',
          'SPUB': enrollment.spub ? 'Yes' : 'No',
          'Remarks': enrollment.remarks || '-'
        }));

        const patientsSheet = XLSX.utils.json_to_sheet(activePatientsData);
        XLSX.utils.book_append_sheet(wb, patientsSheet, 'Active Patients');
      } else {
        // Add empty sheet with header if no patients
        const emptyData = [['Patient Name', 'IC Number', 'Dose per Day', 'Cost per Day (RM)', 'Start Date', 'End Date', 'Last Refill Date', 'SPUB', 'Remarks']];
        const emptySheet = XLSX.utils.aoa_to_sheet(emptyData);
        XLSX.utils.book_append_sheet(wb, emptySheet, 'Active Patients');
      }

      // Generate filename
      const sanitizedDrugName = selectedDrug.name.replace(/[^a-z0-9]/gi, '_').toLowerCase();
      const filename = `${sanitizedDrugName}_active_patients_${dayjs().format('YYYY-MM-DD')}.xlsx`;

      // Write and download
      XLSX.writeFile(wb, filename);
      message.success('Excel file exported successfully');
    } catch (error) {
      console.error('Error exporting to Excel:', error);
      message.error('Error exporting to Excel');
    }
  };

  const handleEditEnrollment = (enrollment) => {
    setEditingEnrollment(enrollment);
    editForm.setFieldsValue({
      ...enrollment,
      prescription_start_date: enrollment.prescription_start_date ? dayjs(enrollment.prescription_start_date) : null,
      prescription_end_date: enrollment.prescription_end_date ? dayjs(enrollment.prescription_end_date) : null,
      latest_refill_date: enrollment.latest_refill_date ? dayjs(enrollment.latest_refill_date) : null
    });
    setEditModalVisible(true);
  };

  const handleDeleteEnrollment = async () => {
    if (!editingEnrollment) {
      message.error('No enrollment selected.');
      return;
    }

    try {
      await enrollmentsAPI.delete(editingEnrollment.id);
      message.success('Enrollment deleted successfully');
      setEditModalVisible(false);
      // Refresh drug enrollments
      await refreshDrugEnrollments();

      // Refresh main data
      await fetchData();
    } catch (error) {
      message.error('Error deleting enrollment');
      console.error('Error:', error);
    }
  };

  const menuItems = [
    {
      key: 'delete',
      label: (
        <Popconfirm
          title="Delete Enrollment"
          description="Are you sure you want to delete this enrollment?"
          onConfirm={handleDeleteEnrollment}
          okText="Delete"
          cancelText="Cancel"
          okType="danger"
        >
          <span style={{ color: '#ff4d4f' }}>Delete Enrollment</span>
        </Popconfirm>
      ),
      icon: <DeleteOutlined style={{ color: '#ff4d4f' }} />
    }
  ];

  const handleUpdateEnrollment = async (values) => {
    try {
      const enrollmentData = {
        ...values,
        spub: !!values.spub,
        is_active: !!values.is_active,
        prescription_start_date: values.prescription_start_date
          ? values.prescription_start_date.format('YYYY-MM-DD')
          : null,
        prescription_end_date: values.prescription_end_date
          ? values.prescription_end_date.format('YYYY-MM-DD')
          : null,
        latest_refill_date: values.latest_refill_date
          ? values.latest_refill_date.format('YYYY-MM-DD')
          : null,
      };

      await enrollmentsAPI.update(editingEnrollment.id, enrollmentData);
      message.success('Enrollment updated successfully');

      setEditModalVisible(false);

      // Refresh drug enrollments
      await refreshDrugEnrollments();

      // Refresh main data
      await fetchData();
    } catch (error) {
      message.error('Error updating enrollment');
      console.error('Error:', error);
    }
  };

  const getUtilizationColor = (active, quota) => {
    const percentage = quota > 0 ? (active / quota) * 100 : 0;
    if (percentage >= 100) return '#ff4d4f';
    if (percentage >= 80) return '#faad14';
    if (percentage >= 50) return '#1890ff';
    return '#52c41a';
  };

  const columns = [
    {
      title: 'Drug Name',
      dataIndex: 'name',
      key: 'name',
      sorter: (a, b) => a.name.localeCompare(b.name),
      defaultSortOrder: 'ascend',
      width: 200,
      render: (name, record) => (
        <Space>
          <MedicineBoxOutlined />
          <div>
            <div style={{ fontWeight: 'bold' }}>{name}</div>
            <div style={{ fontSize: '12px', color: '#666' }}>{record.department_name.includes(' - ') ? record.department_name.split(' - ')[1] : record.department_name}</div>
          </div>
        </Space>
      ),
    },
    {
      title: 'Department',
      dataIndex: 'department_name',
      key: 'department_name',
      responsive: ['lg'],
      width: 150,
      align: 'center',
      sorter: (a, b) => a.department_name.localeCompare(b.department_name),
      render: (department_name) => (department_name.includes(' - ') ? department_name.split(' - ')[1] : department_name),
    },
    {
      title: 'Quota',
      dataIndex: 'quota_number',
      key: 'quota_number',
      responsive: ['sm'],
      align: 'center',
      width: 80,
      sorter: (a, b) => a.quota_number - b.quota_number,
      render: (quota) => <Tag color="blue" style={{ fontSize: 'inherit', padding: '2px 8px' }}>{quota}</Tag>,
    },
    {
      title: 'Active Patients',
      dataIndex: 'current_active_patients',
      key: 'current_active_patients',
      align: 'center',
      width: 130,
      sorter: (a, b) => a.current_active_patients - b.current_active_patients,
      render: (active, record) => {
        // Calculate the utilization percentage
        const percent = record.quota_number > 0
          ? Math.round((active / record.quota_number) * 100)
          : 0;

        // Reuse your existing color logic for the progress bar
        const color = getUtilizationColor(active, record.quota_number);

        return (
          <div>
            {/* Display text like "15 / 20" */}
            <div style={{ marginBottom: '4px' }}>
              <UserOutlined style={{ marginRight: '8px', color: '#666' }} />
              <Tag color={getUtilizationColor(active, record.quota_number)} style={{ fontSize: '12px', padding: '2px 8px' }}>
                {record.current_active_patients}/{record.quota_number}
              </Tag>
            </div>
            {/* The Progress Bar */}
            <Progress
              percent={percent}
              strokeColor={color}
              size="small"
              showInfo={false} // Hides the default "%" text on the bar
            />
          </div>
        );
      },
    }, {
      title: 'Available Slots',
      key: 'available_slots',
      responsive: ['md'],
      align: 'center',
      width: 80,
      sorter: (a, b) => (a.quota_number - a.current_active_patients) - (b.quota_number - b.current_active_patients),
      render: (_, record) => {
        const available = record.quota_number - record.current_active_patients;
        return (
          <Tag color={available > 0 ? 'green' : 'red'} style={{ fontSize: 'inherit', padding: '2px 8px' }}>
            {available}
          </Tag>
        );
      },
    },
    {
      title: 'Price',
      dataIndex: 'price',
      key: 'price',
      responsive: ['lg'],
      align: 'center',
      width: 100,
      sorter: (a, b) => (Number(a.price) || 0) - (Number(b.price) || 0),
      render: (price) => (
        <Space>
          <span>RM {price ? Number(price).toFixed(2) : '0.00'}</span>
        </Space>
      ),
    },
    {
      title: 'Remarks',
      dataIndex: 'remarks',
      key: 'remarks',
      responsive: ['lg'],
      width: 200,
      render: (remarks) => remarks || '-',
    },
  ];

  return (
    <div className="page-container">
      <Card>
        <div style={{ marginBottom: '16px' }}>
          <Row justify="space-between" align="middle" style={{ marginBottom: '16px' }}>
            <Col xs={24} sm={12}>
              <Title level={3} className="page-title">
                <MedicineBoxOutlined style={{ marginRight: '8px' }} />
                Drug Management
              </Title>
            </Col>
            <Col xs={24} sm={12} style={{ textAlign: 'right', marginTop: '8px', '@media (min-width: 768px)': { marginTop: '0' } }}>
              <Space wrap>
                <Segmented
                  value={viewMode}
                  onChange={setViewMode}
                  options={[
                    {
                      label: 'Table',
                      value: 'table',
                      icon: <TableOutlined />,
                    },
                    {
                      label: 'Cards',
                      value: 'card',
                      icon: <AppstoreOutlined />,
                    },
                  ]}
                />
                <Button
                  icon={<ReloadOutlined />}
                  onClick={handleRefresh}
                  loading={loading}
                  title="Refresh"

                >

                </Button>
                <Button
                  type="primary"
                  icon={<PlusOutlined />}
                  onClick={handleAdd}
                  disabled={settingsLoading || !settings?.allowNewDrugs}
                  title={settingsLoading || !settings?.allowNewDrugs ? "Adding new drug is disabled by admin" : "Add new drug"}
                >
                  Add Drug
                </Button>
              </Space>
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
                {departments.map(dept => (
                  <Option key={dept.id} value={dept.id}>
                    {dept.name.includes(' - ') ? dept.name.split(' - ')[1] : dept.name}
                  </Option>
                ))}
              </Select>
            </Col>
            <Col xs={24} sm={16}>
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

        {/* Conditional rendering based on view mode */}
        {viewMode === 'table' ? (
          loading ? (
            <Table
              columns={columns}
              dataSource={[]}
              rowKey="id"
              loading={true}
              pagination={false}
            />
          ) : filteredDrugs.length === 0 ? (
            <Empty
              image={Empty.PRESENTED_IMAGE_SIMPLE}
              description={
                <span>
                  {searchText || selectedDepartment !== 'all'
                    ? 'No drugs found matching your filters'
                    : 'No drugs available'}
                </span>
              }
            >
              {searchText || selectedDepartment !== 'all' ? (
                <Button type="primary" onClick={handleRefresh}>
                  Clear Filters
                </Button>
              ) : (
                <Button type="primary" onClick={handleAdd} disabled={settingsLoading || !settings?.allowNewDrugs}>
                  Add First Drug
                </Button>
              )}
            </Empty>
          ) : (
            <Table
              columns={columns}
              dataSource={filteredDrugs}
              rowKey="id"
              loading={false}
              showSorterTooltip={false}
              pagination={{
                ...pagination,
                showSizeChanger: true,
                showQuickJumper: true,
                showTotal: (total, range) => `${range[0]}-${range[1]} of ${total} drugs`,
                pageSizeOptions: ['5', '10', '20', '50', '100'],
                showLessItems: false
              }}
              onChange={handleTableChange}
              scroll={{ x: 300 }}
              onRow={(record) => ({
                onClick: () => handleDrugClick(record),
                style: { cursor: 'pointer' }
              })}
            />
          )
        ) : (
          <div>
            {loading ? (
              <Row gutter={[16, 16]}>
                {[1, 2, 3, 4, 5, 6].map(i => (
                  <Col xs={24} sm={12} lg={8} xl={6} key={i}>
                    <Card>
                      <Skeleton active paragraph={{ rows: 4 }} />
                    </Card>
                  </Col>
                ))}
              </Row>
            ) : filteredDrugs.length === 0 ? (
              <Empty
                image={Empty.PRESENTED_IMAGE_SIMPLE}
                description={
                  <span>
                    {searchText || selectedDepartment !== 'all'
                      ? 'No drugs found matching your filters'
                      : 'No drugs available'}
                  </span>
                }
              >
                {searchText || selectedDepartment !== 'all' ? (
                  <Button type="primary" onClick={handleRefresh}>
                    Clear Filters
                  </Button>
                ) : (
                  <Button type="primary" onClick={handleAdd} disabled={settingsLoading || !settings?.allowNewDrugs}>
                    Add First Drug
                  </Button>
                )}
              </Empty>
            ) : (
              <>
                <Row gutter={[16, 16]}>
                  {filteredDrugs
                    .slice(
                      (pagination.current - 1) * pagination.pageSize,
                      pagination.current * pagination.pageSize
                    )
                    .map(drug => (
                      <Col xs={24} sm={12} lg={8} xl={6} key={drug.id}>
                        <EnhancedDrugCard
                          drug={drug}
                          onClick={() => handleDrugClick(drug)}
                          onEnroll={(drug) => handleEnrollPatient(drug)}
                        />
                      </Col>
                    ))}
                </Row>

                {/* Pagination for card view */}
                {filteredDrugs.length > 0 && (
                  <div style={{ marginTop: '24px', textAlign: 'center' }}>
                    <Space direction="vertical" size="middle" style={{ width: '100%' }}>
                      <div style={{ color: '#666' }}>
                        Showing {((pagination.current - 1) * pagination.pageSize) + 1} - {Math.min(pagination.current * pagination.pageSize, filteredDrugs.length)} of {filteredDrugs.length} drugs
                      </div>
                      <Space>
                        <Button
                          disabled={pagination.current === 1}
                          onClick={() => setPagination(prev => ({ ...prev, current: prev.current - 1 }))}
                        >
                          Previous
                        </Button>
                        <span style={{ padding: '0 16px' }}>
                          Page {pagination.current} of {Math.ceil(filteredDrugs.length / pagination.pageSize)}
                        </span>
                        <Button
                          disabled={pagination.current >= Math.ceil(filteredDrugs.length / pagination.pageSize)}
                          onClick={() => setPagination(prev => ({ ...prev, current: prev.current + 1 }))}
                        >
                          Next
                        </Button>
                      </Space>
                      <Select
                        value={pagination.pageSize}
                        onChange={(value) => setPagination(prev => ({ ...prev, pageSize: value, current: 1 }))}
                        style={{ width: 120 }}
                      >
                        <Option value={5}>5 per page</Option>
                        <Option value={10}>10 per page</Option>
                        <Option value={20}>20 per page</Option>
                        <Option value={50}>50 per page</Option>
                      </Select>
                    </Space>
                  </div>
                )}
              </>
            )}
          </div>
        )}

      </Card>

      {/* Add/Edit Drug Modal */}
      <Modal
        title={editingDrug ? 'Edit Drug' : 'Add New Drug'}
        open={modalVisible}
        centered
        onCancel={() => {
          setModalVisible(false);
          form.resetFields();

        }}
        footer={null}
        width={600}
        zIndex={1050}
      >
        <Form
          form={form}
          layout="vertical"
          onFinish={handleSubmit}
        >
          <Form.Item
            name="name"
            label="Drug Name"
            rules={[{ required: true, message: 'Please enter drug name' }]}
          >
            <Input placeholder="Enter drug name" />
          </Form.Item>

          <Form.Item
            name="department_id"
            label="Department"
            rules={[{ required: true, message: 'Please select department' }]}
          >
            <Select
              placeholder="Select department"
              popupRender={menu => (
                <div>
                  {menu}
                  <Divider style={{ margin: '8px 0' }} />
                  <Button
                    type="text"
                    icon={<PlusOutlined />}
                    onClick={() => setDeptModalVisible(true)}
                    disabled={settingsLoading || !settings?.allowNewDepartments}
                    style={{ width: '100%' }}
                  >
                    Create New Department
                  </Button>
                </div>
              )}
            >
              {departments.map(dept => (
                <Option key={dept.id} value={dept.id}>
                  {dept.name.includes(' - ') ? dept.name.split(' - ')[1] : dept.name}
                </Option>
              ))}
            </Select>
          </Form.Item>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="quota_number"
                label="Quota Number"
                rules={[{ required: true, message: 'Please enter quota number' }]}
              >
                <InputNumber
                  min={0}
                  style={{ width: '100%' }}
                  placeholder="Enter quota number"
                  autoComplete="off"
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="price"
                label="Price per SKU (RM)"
                rules={[{ required: false, message: 'Please enter price' }]}
              >
                <InputNumber
                  min={0}
                  step={0.01}
                  style={{ width: '100%' }}
                  placeholder="Enter price SKU"
                  autoComplete="off"
                />
              </Form.Item>
            </Col>
          </Row>


          <Form.Item
            name="remarks"
            label="Remarks"
          >
            <Input.TextArea
              rows={3}
              placeholder="Enter any remarks or notes"
              autoComplete="off"
            />
          </Form.Item>

          <Form.Item style={{ marginBottom: 0, textAlign: 'right' }}>
            <Space>
              <Button onClick={() => setModalVisible(false)}>
                Cancel
              </Button>
              <Button type="primary" htmlType="submit">
                {editingDrug ? 'Update' : 'Create'}
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>

      {/* Create Department Modal */}
      <Modal
        title="Create New Department"
        open={deptModalVisible}
        onCancel={() => {
          setDeptModalVisible(false);
          deptForm.resetFields();
        }}
        footer={null}
        width={400}
      >
        <Form
          form={deptForm}
          layout="vertical"
          onFinish={handleCreateDepartment}
        >
          <Form.Item
            name="name"
            label="Department Name"
            rules={[{ required: true, message: 'Please enter department name' }]}
          >
            <Input placeholder="Enter department name" />
          </Form.Item>

          <Form.Item style={{ marginBottom: 0, textAlign: 'right' }}>
            <Space>
              <Button onClick={() => setDeptModalVisible(false)}>
                Cancel
              </Button>
              <Button type="primary" htmlType="submit">
                Create Department
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>

      {/* Enroll Patient Modal */}
      <Modal
        title={`Enroll Patient to ${selectedDrug?.name || 'Drug'}`}
        open={enrollModalVisible}
        onCancel={() => {
          setEnrollModalVisible(false);
          enrollForm.resetFields();
          setPatientSearchText('');
          refreshDrugEnrollments();
          fetchData();
        }}
        footer={null}
        width="95%"
        style={{ maxWidth: '700px' }}
        centered
        destroyOnHidden
        afterOpenChange={(open) => {
          if (open && patientSelectRef.current) {
            setTimeout(() => {
              patientSelectRef.current.focus();
            }, 100);
          }
        }}
      >
        {selectedDrug && (
          <div style={{
            marginBottom: '16px',
            padding: '12px',
            background: '#f0f8ff',
            borderRadius: '6px',
            border: '1px solid #d6e4ff'
          }}>
            <Row gutter={16}>
              <Col span={12}>
                <div><strong>Drug:</strong> {selectedDrug.name}</div>
                <div><strong>Department:</strong> {selectedDrug.department_name}</div>
              </Col>
              <Col span={12}>
                <div><strong>Available Slots:</strong> {selectedDrug.quota_number - selectedDrug.current_active_patients}</div>
                <div><strong>Price:</strong> RM {Number(selectedDrug.price).toFixed(2)} per unit</div>
              </Col>
              <Col span={24}>
                <div><strong>Remarks:</strong> {selectedDrug.remarks} </div>
              </Col>
            </Row>
          </div>
        )}

        <Form
          form={enrollForm}
          layout="vertical"
          onFinish={handleEnrollSubmit}
          size="small"
        >
          <Form.Item name="drug_id" style={{ display: 'none' }}>
            <Input type="hidden" />
          </Form.Item>

          {/* Row 1: Patient Selection */}
          <Row gutter={[12, 12]}>
            <Col xs={24} sm={24}>

              <Form.Item
                name="patient_id"
                label="Patient"
                rules={[{ required: true, message: 'Please select a patient' }]}
                style={{ marginBottom: '0' }}
              >
                <Select
                  ref={patientSelectRef}
                  placeholder="Search patient..."
                  showSearch
                  value={patientSearchText ? undefined : enrollForm.getFieldValue('patient_id')}
                  onSearch={(value) => setPatientSearchText(value)}
                  filterOption={(input, option) => {
                    if (option.value === 'create_new') return true;
                    const patient = patients.find(p => p.id === option.value);
                    if (patient) {
                      const searchText = `${patient.name} ${patient.ic_number}`.toLowerCase();
                      return searchText.indexOf(input.toLowerCase()) >= 0;
                    }
                    return false;
                  }}
                  notFoundContent={
                    patientSearchText ? (
                      <div style={{ textAlign: 'center', padding: '8px' }}>
                        <div style={{ marginBottom: '8px', fontSize: '12px' }}>No patient found</div>
                        <Button
                          type="primary"
                          size="small"
                          onClick={() => setShowCreatePatient(true)}
                        >
                          Create New Patient
                        </Button>
                      </div>
                    ) : null
                  }
                >
                  {patients.map(patient => (
                    <Option key={patient.id} value={patient.id}>
                      {patient.name} ({patient.ic_number})
                    </Option>
                  ))}
                </Select>
              </Form.Item>
            </Col></Row>

          {/* Row 2: Dose, Duration, Start Date */}
          <Row gutter={[12, 12]} style={{ marginTop: '12px' }}>
            <Col xs={24} sm={8}>
              <Form.Item
                name="dose_per_day"
                label="Dose"
                style={{ marginBottom: '0' }}
              >
                <Input
                  style={{ width: '100%' }}
                  placeholder="e.g. 10 mg tds"
                  autoComplete="off"
                />
              </Form.Item>
            </Col>
            <Col xs={12} sm={8}>
              <Form.Item
                name="duration"
                label="Duration (days)"
                tooltip="Auto-calculates end date"
                style={{ marginBottom: '0' }}
              >
                <InputNumber
                  min={1}
                  max={3650}
                  style={{ width: '100%' }}
                  placeholder="e.g. 30"
                  onChange={handleDurationChange}
                />
              </Form.Item>
            </Col>
            <Col xs={12} sm={8}>
              <Form.Item
                name="prescription_start_date"
                label="Start Date"
                rules={[{ required: true, message: 'Required' }]}
                style={{ marginBottom: '0' }}
              >
                <CustomDateInput
                  style={{ width: '100%' }}
                  onChange={handleStartDateChange}
                  placeholder="Select date or enter ddmmyy"
                />
              </Form.Item>
            </Col>
          </Row>

          {/* Row 3: End Date, Refill Date, Switches */}
          <Row gutter={[12, 12]} style={{ marginTop: '12px' }}>
            <Col xs={12} sm={8}>
              <Form.Item
                name="prescription_end_date"
                label="End Date"
                style={{ marginBottom: '0' }}
                tooltip="PS End Date or TCA Klinik Pakar"
              >
                <CustomDateInput
                  style={{ width: '100%' }}
                  placeholder="Enter ddmmyy or select date"
                />
              </Form.Item>
            </Col>
            <Col xs={12} sm={8}>
              <Form.Item
                name="latest_refill_date"
                label="Last Refill"
                style={{ marginBottom: '0' }}
              >
                <CustomDateInput
                  style={{ width: '100%' }}
                  placeholder="enter ddmmyy"
                />
              </Form.Item>
            </Col>
            <Col xs={24} sm={8}>
              <div style={{ display: 'flex', gap: '16px', marginTop: '24px', marginLeft: '8px' }}>
                <Form.Item
                  name="spub"
                  label="SPUB"
                  valuePropName="checked"
                  tooltip="Refills at other facilities"
                  style={{ marginBottom: 0 }}
                >
                  <Switch size="default" checkedChildren={<CheckOutlined />} unCheckedChildren={<CloseOutlined />} />
                </Form.Item>
                <Form.Item
                  name="is_active"
                  label="Active"
                  valuePropName="checked"
                  tooltip="Counts toward quota"
                  style={{ marginBottom: 0 }}
                >
                  <Switch size="default" defaultChecked checkedChildren={<CheckOutlined />} unCheckedChildren={<CloseOutlined />} />                </Form.Item>
              </div>
            </Col>
          </Row>

          {/* Row 4: Cost per day and Remarks */}
          <Row gutter={[12, 12]} style={{ marginTop: '12px' }}>
            <Col xs={24} sm={8}>
              <Form.Item
                name="cost_per_day"
                label="Cost per Day"
                tooltip={(() => {
                  if (selectedDrug) {
                    return `Drug: ${selectedDrug.name}\n Price: RM ${parseFloat(selectedDrug.price).toFixed(2)}\n`;
                  }
                  return "Cost per day";
                })()}
                style={{ marginBottom: '0' }}
              >
                <CostPerDayInput
                  onChange={(value) => {
                    enrollForm.setFieldsValue({ cost_per_day: value });
                  }}
                  drugInfo={selectedDrug}
                  autoComplete="off"
                  placeholder={(() => {
                    if (selectedDrug) {
                      return `RM ${parseFloat(selectedDrug.price).toFixed(2)} per tab/unit`;
                    }
                    return "total cost per day";
                  })()}
                />
              </Form.Item>
            </Col>
            <Col xs={24} sm={16}>
              <Form.Item
                name="remarks"
                label="Remarks"
                style={{ marginBottom: '16px' }}
              >
                <Input.TextArea
                  rows={2}
                  placeholder="Started by Dr Vicknesh s/t Dr Johan, SPUB to Hosp Kota Tinggi"
                  style={{ resize: 'none' }}
                  autoComplete="off"
                />
              </Form.Item>
            </Col>
          </Row>

          {/* Row 5: Action Buttons */}
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            paddingTop: '8px',
            borderTop: '1px solid #f0f0f0'
          }}>
            <div style={{ fontSize: '12px', color: '#666' }}>
              Press <kbd style={{
                background: '#f5f5f5',
                padding: '2px 4px',
                borderRadius: '3px',
                fontSize: '11px'
              }}>Ctrl+Enter</kbd> to save
            </div>
            <Space>
              <Button onClick={() => {
                setEnrollModalVisible(false);
                enrollForm.resetFields();
                setPatientSearchText('');
              }}>
                Cancel
              </Button>
              <Button type="primary"
                htmlType="submit"
                disabled={settingsLoading || !settings?.allowNewEnrollments}
                title={settingsLoading || !settings?.allowNewEnrollments ? "Adding new enrollments is disabled by admin" : "Add new enrollment"}
              >
                Enroll Patient
              </Button>
            </Space>
          </div>
        </Form>
      </Modal>

      {/* Create Patient Modal */}
      <Modal
        title="Create New Patient"
        open={showCreatePatient}
        onCancel={() => {
          setShowCreatePatient(false);
          patientForm.resetFields();
          setPatientSearchText('');
        }}
        footer={null}
        width={400}
        centered
        destroyOnHidden
        zIndex={2060}
        afterOpenChange={(open) => {
          if (open) {
            setTimeout(() => {
              const nameInput = document.querySelector('input[placeholder="Enter patient name"]');
              if (nameInput) {
                nameInput.focus();
              }
            }, 100);
          }
        }}
      >
        <Form
          form={patientForm}
          layout="vertical"
          onFinish={handleCreatePatient}
          size="small"
        >
          <Form.Item
            name="name"
            label="Patient Name"
            rules={[{ required: true, message: 'Please enter patient name' }]}
            normalize={(value) => value ? value.toUpperCase() : value}
            style={{ marginBottom: '16px' }}
          >
            <Input
              placeholder="Enter patient name"
              autoComplete="off"
              autoFocus
              onPressEnter={() => {
                const icInput = document.querySelector('input[placeholder="Enter IC number, passport, or other identifier"]');
                if (icInput) icInput.focus();
              }}
            />
          </Form.Item>

          <Form.Item
            name="ic_number"
            label="IC Number / Passport / Other ID"
            rules={[{ required: true, message: 'Please enter patient identifier' }]}
            style={{ marginBottom: '20px' }}
          >
            <Input
              placeholder="Enter IC number, passport, or other identifier"
              autoComplete="off"
              onPressEnter={() => patientForm.submit()}
            />
          </Form.Item>

          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            paddingTop: '8px',
            borderTop: '1px solid #f0f0f0'
          }}>
            <div style={{ fontSize: '12px', color: '#666' }}>
              Press <kbd style={{
                background: '#f5f5f5',
                padding: '2px 4px',
                borderRadius: '3px',
                fontSize: '11px'
              }}>Enter</kbd> to create
            </div>
            <Space>
              <Button onClick={() => {
                setShowCreatePatient(false);
                patientForm.resetFields();
                setPatientSearchText('');
              }}>
                Cancel
              </Button>
              <Button type="primary" htmlType="submit">
                Create Patient
              </Button>
            </Space>
          </div>
        </Form>
      </Modal>

      {/* Drug Details Modal */}

      <Modal
        title={
          <div className="quota-title" style={{ '--dept-color': deptColor }}>
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
        open={drugDetailsModalVisible}
        onCancel={() => setDrugDetailsModalVisible(false)}
        footer={null}
        width="95%"
        style={{ maxWidth: '1000px' }}
      >
        {selectedDrug && (
          <div>
            {/* Drug Information */}
            <Card size="small" className='quota-box' style={{ '--dept-color': deptColor, marginBottom: '16px' }}>
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
                <Text strong>Price: </Text>
                <Text>RM {Number(selectedDrug.price).toFixed(2)} per unit</Text>
                <br />
                <Text strong>Remarks: </Text>
                <Text>{selectedDrug.remarks || '-'}</Text>
              </div>
            </Card>

            {/* Action Buttons */}
            <Card size="small" style={{ marginBottom: '16px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Space>
                  <Button
                    type="primary"
                    icon={<UserAddOutlined />}
                    onClick={() => handleEnrollPatient(selectedDrug)}
                    disabled={
                      // Disable if quota is full
                      (selectedDrug.quota_number - selectedDrug.current_active_patients) <= 0 ||

                      // OR disable if settings are loading or new enrollments are disallowed
                      settingsLoading || !settings?.allowNewEnrollments
                    }
                    // Optional: Add a title to explain why it might be disabled
                    title={
                      (selectedDrug.quota_number - selectedDrug.current_active_patients) <= 0
                        ? "Quota is full"
                        : (!settings?.allowNewEnrollments ? "Adding new enrollments is disabled by admin" : "Enroll new patient")
                    }
                  >
                    Enroll Patient
                  </Button>

                  <Button
                    icon={<EditOutlined />}
                    disabled={settingsLoading || !settings?.allowNewDrugs}
                    title={settingsLoading || !settings?.allowNewDrugs ? "Editing drug is disabled" : "Edit drug"}
                    onClick={() => handleEdit(selectedDrug)}
                  >

                  </Button>
                  <Popconfirm
                    title="Are you sure you want to delete this drug?"
                    description="This will also remove all associated patient enrollments."
                    onConfirm={() => {
                      handleDelete(selectedDrug.id);
                      setDrugDetailsModalVisible(false);
                    }}
                    okText="Yes"
                    cancelText="No"
                  >
                    <Button
                      icon={<DeleteOutlined />}
                      disabled={settingsLoading || !settings?.allowNewDrugs}
                      title={settingsLoading || !settings?.allowNewDrugs ? "Deleting drug is disabled" : "Delete drug"}
                      danger
                    >

                    </Button>
                  </Popconfirm>
                </Space>

                <Button
                  icon={<FaFileExcel style={{ fontSize: '16px' }} />}
                  onClick={handleExportToExcel}
                  title="Export drug and active patients to Excel"
                  style={{
                    backgroundColor: '#217346',
                    borderColor: '#217346',
                    color: '#ffffff',
                    fontWeight: 500
                  }}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.backgroundColor = '#1d5f38';
                    e.currentTarget.style.borderColor = '#1d5f38';
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.backgroundColor = '#217346';
                    e.currentTarget.style.borderColor = '#217346';
                  }}
                >
                  Export
                </Button>
              </div>
            </Card>

            {/* Active Enrollments Table */}
            <Card title="Active Patient Enrollments" size="small">
              <Table
                dataSource={drugEnrollments}
                rowKey="id"
                pagination={{ pageSize: 10 }}
                showSorterTooltip={false}
                onRow={(record) => ({
                  onClick: () => handleEditEnrollment(record),
                  style: { cursor: 'pointer' }
                })}
                columns={[
                  {
                    title: 'Patient',
                    dataIndex: 'patient_name',
                    key: 'patient_name',
                    sorter: (a, b) => a.patient_name.localeCompare(b.patient_name),
                    defaultSortOrder: 'ascend',
                    render: (text, record) => (
                      <div>
                        <div style={{ fontWeight: 'bold' }}>{text}</div>
                        <Text type="secondary" style={{ fontSize: '12px' }}>
                          {record.ic_number}
                        </Text>
                      </div>
                    ),
                  },
                  {
                    title: 'Dose',
                    dataIndex: 'dose_per_day',
                    key: 'dose_per_day',
                    responsive: ['md'],
                    render: (value) => value || '-',
                  },
                  {
                    title: 'Cost/Day',
                    dataIndex: 'cost_per_day',
                    key: 'cost_per_day',
                    responsive: ['lg'],
                    render: (value) => value ? `RM ${parseFloat(value).toFixed(2)}` : '-',
                  },
                  {
                    title: 'Start Date',
                    dataIndex: 'prescription_start_date',
                    key: 'prescription_start_date',
                    responsive: ['md'],
                    sorter: (a, b) => new Date(a.prescription_start_date) - new Date(b.prescription_start_date),
                    render: (date) => date ? dayjs(date).format('DD/MM/YYYY') : '-',
                  },
                  {
                    title: 'Last Refill',
                    dataIndex: 'latest_refill_date',
                    key: 'latest_refill_date',
                    sorter: (a, b) => new Date(a.latest_refill_date || 0) - new Date(b.latest_refill_date || 0),
                    render: (date) => {
                      if (!date) return <Tag color="orange" style={{ fontSize: 'inherit', padding: '2px 8px' }}>Never</Tag>;
                      const daysSince = dayjs().diff(dayjs(date), 'day');
                      if (daysSince > 180) return <Tag color="red" style={{ fontSize: 'inherit', padding: '2px 8px' }}>{dayjs(date).format('DD/MM/YYYY')}</Tag>;
                      if (daysSince > 90) return <Tag color="orange" style={{ fontSize: 'inherit', padding: '2px 8px' }}>{dayjs(date).format('DD/MM/YYYY')}</Tag>;
                      return <Tag color="green" style={{ fontSize: 'inherit', padding: '2px 8px' }}>{dayjs(date).format('DD/MM/YYYY')}</Tag>;
                    },
                  },
                  {
                    title: 'Remarks',
                    dataIndex: 'remarks',
                    key: 'remarks',
                    responsive: ['sm'],
                    width: 200,
                    render: (value) => value || '-',
                  },
                  {
                    title: 'SPUB?',
                    key: 'status',
                    responsive: ['lg'],
                    render: (_, record) => (
                      <Space direction="vertical" size="small">
                        {record.spub && <Tag color="blue" style={{ fontSize: 'inherit', padding: '2px 8px' }}>SPUB</Tag>}
                      </Space>
                    ),
                  },
                ]}
                scroll={{ x: 'max-content' }}
              />
            </Card>

            {/* Inactive Enrollments Table */}
            <Card title="Inactive (Defaulted) Patients" size="small" style={{ marginTop: '16px' }}>
              <Table
                dataSource={inactiveEnrollments}
                rowKey="id"
                pagination={{ pageSize: 5 }}
                onRow={(record) => ({
                  onClick: () => handleEditEnrollment(record),
                  style: { cursor: 'pointer' }
                })}
                columns={[
                  {
                    title: 'Patient',
                    dataIndex: 'patient_name',
                    key: 'patient_name',
                    render: (text, record) => (
                      <div>
                        <div style={{ fontWeight: 'bold' }}>{text}</div>
                        <Text type="secondary" style={{ fontSize: '12px' }}>
                          {record.ic_number}
                        </Text>
                      </div>
                    ),
                  },
                  {
                    title: 'Dose',
                    dataIndex: 'dose_per_day',
                    key: 'dose_per_day',
                    render: (value) => value || '-',
                  },
                  {
                    title: 'Cost/Day',
                    dataIndex: 'cost_per_day',
                    key: 'cost_per_day',
                    render: (value) => value ? `RM ${parseFloat(value).toFixed(2)}` : '-',
                  },
                  {
                    title: 'Start Date',
                    dataIndex: 'prescription_start_date',
                    key: 'prescription_start_date',
                    render: (date) => date ? dayjs(date).format('DD/MM/YYYY') : '-',
                  },
                  {
                    title: 'Last Refill',
                    dataIndex: 'latest_refill_date',
                    key: 'latest_refill_date',
                    render: (date) => {
                      if (!date) return <Tag color="orange" style={{ fontSize: 'inherit', padding: '2px 8px' }}>Never</Tag>;
                      const daysSince = dayjs().diff(dayjs(date), 'day');
                      if (daysSince > 180) return <Tag color="red" style={{ fontSize: 'inherit', padding: '2px 8px' }}>{dayjs(date).format('DD/MM/YYYY')}</Tag>;
                      if (daysSince > 90) return <Tag color="orange" style={{ fontSize: 'inherit', padding: '2px 8px' }}>{dayjs(date).format('DD/MM/YYYY')}</Tag>;
                      return <Tag color="green" style={{ fontSize: 'inherit', padding: '2px 8px' }}>{dayjs(date).format('DD/MM/YYYY')}</Tag>;
                    },
                  },
                  {
                    title: 'SPUB?',
                    key: 'status',
                    render: (_, record) => (
                      <Space direction="vertical" size="small">
                        {record.spub && <Tag color="blue" style={{ fontSize: 'inherit', padding: '2px 8px' }}>SPUB</Tag>}
                      </Space>
                    ),
                  },
                ]}
                scroll={{ x: 'max-content' }}
              />
            </Card>
          </div>
        )}
      </Modal>

      {/* Edit Enrollment Modal */}
      <Modal
        title={
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span>Edit Enrollment</span>
            <Dropdown
              menu={{ items: menuItems }}
              trigger={['click']}
              placement="bottomRight">
              <Button
                type="text"
                icon={<MoreOutlined />}
                style={{ border: 'none', boxShadow: 'none', marginRight: '0' }} />
            </Dropdown>
          </div>
        }
        open={editModalVisible}
        onCancel={() => {
          setEditModalVisible(false);
          enrollForm.resetFields();
          setPatientSearchText('');
          refreshDrugEnrollments();
          fetchData();
        }}
        footer={null}
        width="95%"
        style={{ maxWidth: '700px' }}
        closable={false}
        centered
        destroyOnHidden
      >
        <Form
          form={editForm}
          layout="vertical"
          onFinish={handleUpdateEnrollment}
          size="small"
        >
          {/* Row 1: Patient and Drug Selection */}
          <Row gutter={[12, 12]}>
            <Col xs={24} sm={12}>
              <Form.Item
                name="patient_id"
                label="Patient"
                rules={[{ required: true, message: 'Please select a patient' }]}
                style={{ marginBottom: '0' }}
              >
                <Select
                  ref={patientSelectRef}
                  placeholder="Search patient..."
                  showSearch
                  style={{
                    pointerEvents: editingEnrollment ? 'none' : 'auto',
                    background: editingEnrollment ? '#fafafa' : '#ffffff',
                  }}
                  value={patientSearchText ? undefined : editForm.getFieldValue('patient_id')}
                  onSearch={(value) => setPatientSearchText(value)}
                  filterOption={(input, option) => {
                    if (option.value === 'create_new') return true;
                    const patient = patients.find(p => p.id === option.value);
                    if (patient) {
                      const searchText = `${patient.name} ${patient.ic_number}`.toLowerCase();
                      return searchText.indexOf(input.toLowerCase()) >= 0;
                    }
                    return false;
                  }}
                  notFoundContent={
                    patientSearchText ? (
                      <div style={{ textAlign: 'center', padding: '8px' }}>
                        <div style={{ marginBottom: '8px', fontSize: '12px' }}>No patient found</div>
                        <Button
                          type="primary"
                          size="small"
                          onClick={() => setShowCreatePatient(true)}
                        >
                          Create New Patient
                        </Button>
                      </div>
                    ) : null
                  }
                >
                  {patients.map(patient => (
                    <Option key={patient.id} value={patient.id}>
                      {patient.name} ({patient.ic_number})
                    </Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col xs={24} sm={12}>
              <Form.Item
                name="drug_id"
                label="Drug"
                rules={[{ required: true, message: 'Please select a drug' }]}
                style={{ marginBottom: '0' }}
              >
                <Select
                  placeholder="Search drug..."
                  showSearch
                  style={{
                    pointerEvents: editingEnrollment ? 'none' : 'auto',
                    background: editingEnrollment ? '#fafafa' : '#ffffff',
                  }}
                  filterOption={(input, option) => {
                    const drug = drugs.find(d => d.id === option.value);
                    if (drug) {
                      const searchText = `${drug.name} ${drug.department_name || ''}`.toLowerCase();
                      return searchText.indexOf(input.toLowerCase()) >= 0;
                    }
                    return false;
                  }}
                >
                  {drugs.map(drug => (
                    <Option key={drug.id} value={drug.id}>
                      {drug.name} ({drug.department_name})
                    </Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
          </Row>

          {/* Row 2: Dose, Duration, Start Date */}
          <Row gutter={[12, 12]} style={{ marginTop: '12px' }}>
            <Col xs={24} sm={8}>
              <Form.Item
                name="dose_per_day"
                label="Dose"
                style={{ marginBottom: '0' }}
              >
                <Input
                  style={{ width: '100%' }}
                  placeholder="e.g. 10 mg tds"
                  autoComplete="off"
                />
              </Form.Item>
            </Col>
            <Col xs={12} sm={8}>
              <Form.Item
                name="duration"
                label="Duration (days)"
                tooltip="Auto-calculates end date"
                style={{ marginBottom: '0' }}
              >
                <InputNumber
                  min={1}
                  max={3650}
                  style={{ width: '100%' }}
                  placeholder="e.g. 30"
                />
              </Form.Item>
            </Col>
            <Col xs={12} sm={8}>
              <Form.Item
                name="prescription_start_date"
                label="Start Date"
                rules={[{ required: true, message: 'Required' }]}
                style={{ marginBottom: '0' }}
              >
                <CustomDateInput
                  style={{ width: '100%' }}
                  placeholder="Enter ddmmyy or select date"
                />
              </Form.Item>
            </Col>
          </Row>

          {/* Row 3: End Date, Refill Date, Switches */}
          <Row gutter={[12, 12]} style={{ marginTop: '12px' }}>
            <Col xs={12} sm={8}>
              <Form.Item
                name="prescription_end_date"
                label="End Date"
                tooltip="PS End Date or TCA Klinik Pakar"
                style={{ marginBottom: '0' }}
              >
                <CustomDateInput
                  style={{ width: '100%' }}
                  placeholder="Enter ddmmyy or select date"
                />
              </Form.Item>
            </Col>
            <Col xs={12} sm={8}>
              <Form.Item
                name="latest_refill_date"
                label="Last Refill"
                style={{ marginBottom: '0' }}
              >
                <CustomDateInput
                  style={{ width: '100%' }}
                  placeholder="enter ddmmyy"
                />
              </Form.Item>
            </Col>

            <Col xs={24} sm={8}>
              <div style={{ display: 'flex', gap: '24px', marginTop: '24px', marginLeft: '8px' }}>
                <Form.Item
                  name="spub"
                  label="SPUB"
                  valuePropName="checked"
                  tooltip="Refills at other facilities"
                  style={{ marginBottom: 0 }}
                >
                  <Switch
                    size="default"
                    checkedChildren={<CheckOutlined />}
                    unCheckedChildren={<CloseOutlined />}
                  />
                </Form.Item>

                <Form.Item
                  name="is_active"
                  label="Active"
                  valuePropName="checked"
                  tooltip="Counts toward quota"
                  style={{ marginBottom: 0 }}
                >
                  <Switch
                    size="default"
                    checkedChildren={<CheckOutlined />}
                    unCheckedChildren={<CloseOutlined />}
                  />
                </Form.Item>
              </div>
            </Col>

          </Row>

          {/* Row 4: Cost per day and Remarks */}
          <Row gutter={[12, 12]} style={{ marginTop: '12px' }}>
            <Col xs={24} sm={8}>
              <Form.Item
                name="cost_per_day"
                label="Cost per Day"
                tooltip={(() => {
                  const selectedDrug = drugs.find(d => d.id === editForm.getFieldValue('drug_id'));
                  if (selectedDrug) {
                    return `Drug: ${selectedDrug.name}\nPrice: RM ${parseFloat(selectedDrug.price).toFixed(2)}`;
                  }
                  return "Enter the daily cost for this enrollment.";
                })()}
                style={{ marginBottom: '0' }}
              >
                <CostPerDayInput
                  onChange={(value) => editForm.setFieldsValue({ cost_per_day: value })}
                  drugInfo={drugs.find(d => d.id === editForm.getFieldValue('drug_id'))}
                  placeholder={(() => {
                    const selectedDrug = drugs.find(d => d.id === form.getFieldValue('drug_id'));
                    if (selectedDrug) {
                      return `RM ${parseFloat(selectedDrug.price).toFixed(2)} per tab/unit`;
                    }
                    return "total cost per day";
                  })()}
                />
              </Form.Item>
            </Col>
            <Col xs={24} sm={16}>
              <Form.Item
                name="remarks"
                label="Remarks"
                style={{ marginBottom: '0' }}
              >
                <Input.TextArea
                  rows={2}
                  placeholder="Started by Dr Aaron s/t Dr Johan Siow, SPUB to KK Kuala Nerus"
                  style={{ resize: 'none' }}
                  autoComplete="off"
                />
              </Form.Item>
            </Col>
          </Row>

          {/* Row 5: Action Buttons */}
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            paddingTop: '8px',
            borderTop: '1px solid #f0f0f0'
          }}>
            <div style={{ fontSize: '12px', color: '#666' }}>
              Press <kbd style={{
                background: '#f5f5f5',
                padding: '2px 4px',
                borderRadius: '3px',
                fontSize: '11px'
              }}>Ctrl+Enter</kbd> to save
            </div>
            <Space>
              <Button onClick={() => { setEditModalVisible(false); refreshDrugEnrollments(); fetchData(); }}>
                Cancel
              </Button>
              <Button type="primary" htmlType="submit">
                Update Enrollment
              </Button>
            </Space>
          </div>
        </Form>
      </Modal>
    </div>
  );
};

export default DrugListPage;
