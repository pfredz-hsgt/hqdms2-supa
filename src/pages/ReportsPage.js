import React, { useState, useEffect } from 'react';
import {
  Card,
  Typography,
  Row,
  Col,
  Button,
  Select,
  Table,
  Statistic,
  Space,
  message,
  Tabs,
  Alert,
  Input,
  Progress
} from 'antd';
import {
  FileTextOutlined,
  DownloadOutlined,
  DollarOutlined,
  UserOutlined,
  MedicineBoxOutlined,
  WarningOutlined,
  BarChartOutlined,
  SearchOutlined
} from '@ant-design/icons';
import { reportsAPI, departmentsAPI, enrollmentsAPI } from '../services/api';
import dayjs from 'dayjs';
import CountUp from 'react-countup';
import { FaFileExcel } from 'react-icons/fa';
import * as XLSX from 'xlsx';
import './ReportsPage.css';
import '../components/EnhancedDrugCard.css';

const { Title, Text } = Typography;
const { Option } = Select;
// Removed TabPane import as we'll use items prop instead

const ReportsPage = () => {
  const [departments, setDepartments] = useState([]);
  const [loading, setLoading] = useState(false);
  const [reportData, setReportData] = useState({});
  const [dashboardData, setDashboardData] = useState(null);
  const [selectedDepartment, setSelectedDepartment] = useState('all');
  const [selectedDateRange] = useState([dayjs().startOf('year'), dayjs().endOf('year')]);
  const [yearlyCostData, setYearlyCostData] = useState(null);

  useEffect(() => {
    fetchDepartments();
    fetchDashboardData();
    fetchYearlyCosts();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);



  const fetchDepartments = async () => {
    try {
      const response = await departmentsAPI.getAll();
      setDepartments(response.data);
    } catch (error) {
      console.error('Error fetching departments:', error);
    }
  };

  const fetchDashboardData = async () => {
    try {
      const response = await reportsAPI.getDashboard();
      setDashboardData(response.data);
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
    }
  };

  const fetchCostAnalysis = async () => {
    setLoading(true);
    try {
      const params = {
        start_date: selectedDateRange[0]?.format('YYYY-MM-DD'),
        end_date: selectedDateRange[1]?.format('YYYY-MM-DD'),
        department_id: selectedDepartment !== 'all' ? selectedDepartment : undefined
      };
      const response = await reportsAPI.getCostAnalysis(params);
      setReportData(prev => ({ ...prev, costAnalysis: response.data }));
    } catch (error) {
      message.error('Error fetching cost analysis report');
      console.error('Cost analysis error:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchQuotaUtilization = async () => {
    setLoading(true);
    try {
      const params = selectedDepartment !== 'all' ? { department_id: selectedDepartment } : {};
      const response = await reportsAPI.getQuotaUtilization(params);
      setReportData(prev => ({ ...prev, quotaUtilization: response.data }));
    } catch (error) {
      message.error('Error fetching quota utilization report');
      console.error('Quota utilization error:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchDefaulters = async () => {
    setLoading(true);
    try {
      const params = selectedDepartment !== 'all' ? { department_id: selectedDepartment } : {};
      const response = await reportsAPI.getDefaulters(params);
      setReportData(prev => ({ ...prev, defaulters: response.data }));
    } catch (error) {
      message.error('Error fetching defaulter report');
      console.error('Defaulters error:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchYearlyCosts = async () => {
    setLoading(true);
    try {
      const params = {
        department_id: selectedDepartment !== 'all' ? selectedDepartment : undefined
      };
      const response = await enrollmentsAPI.getYearlyCosts(params);
      setYearlyCostData(response.data);
    } catch (error) {
      message.error('Error fetching yearly cost report');
      console.error('Yearly costs error:', error);
    } finally {
      setLoading(false);
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


  const handleExport = async (reportType) => {
    try {
      const wb = XLSX.utils.book_new();
      let filename = '';

      switch (reportType) {
        case 'yearly_costs':
          if (!yearlyCostData) {
            message.warning('Please generate the report first');
            return;
          }

          // Summary sheet
          const summaryData = [
            ['Report Type', 'Yearly Cost Report'],
            ['Export Date', dayjs().format('DD/MM/YYYY HH:mm:ss')],
            ['Department Filter', selectedDepartment !== 'all'
              ? departments.find(d => d.id.toString() === selectedDepartment)?.name || 'All'
              : 'All Departments'],
            [''],
            ['Summary Statistics', ''],
            ['Total Annual Cost (RM)', Number(yearlyCostData.summary.totalCost).toFixed(2)],
            ['Total Enrollments', yearlyCostData.summary.totalEnrollments],
            ['Active Enrollments', yearlyCostData.summary.activeEnrollments],
            ['Avg Cost per Active Enrollment (RM)', Number(yearlyCostData.summary.averageCostPerEnrollment).toFixed(2)]
          ];
          const summarySheet = XLSX.utils.aoa_to_sheet(summaryData);
          XLSX.utils.book_append_sheet(wb, summarySheet, 'Summary');

          // Department totals sheet
          const deptTotalsData = [
            ['Department', 'Total Cost (RM)', 'Enrollment Count']
          ];
          Object.entries(yearlyCostData.departmentTotals).forEach(([dept, data]) => {
            const deptName = dept.includes(' - ') ? dept.split(' - ')[1] : dept;
            deptTotalsData.push([deptName, Number(data.total).toFixed(2), data.count]);
          });
          const deptSheet = XLSX.utils.aoa_to_sheet(deptTotalsData);
          XLSX.utils.book_append_sheet(wb, deptSheet, 'Department Totals');

          // Enrollments sheet
          if (yearlyCostData.enrollments && yearlyCostData.enrollments.length > 0) {
            const enrollmentsData = yearlyCostData.enrollments.map(record => ({
              'Patient Name': record.patient_name || '-',
              'IC Number': record.ic_number || '-',
              'Department': record.department_name?.includes(' - ')
                ? record.department_name.split(' - ')[1]
                : (record.department_name || '-'),
              'Drug Name': record.drug_name || '-',
              'Cost per Day (RM)': record.cost_per_day ? parseFloat(record.cost_per_day).toFixed(2) : '-',
              'Yearly Cost (RM)': record.calculated_yearly_cost
                ? Number(record.calculated_yearly_cost).toFixed(2)
                : '0.00',
              'Status': record.is_active ? 'Active' : 'Inactive'
            }));
            const enrollmentsSheet = XLSX.utils.json_to_sheet(enrollmentsData);
            XLSX.utils.book_append_sheet(wb, enrollmentsSheet, 'Enrollments');
          } else {
            // Add empty sheet with header if no enrollments
            const emptyData = [['Patient Name', 'IC Number', 'Department', 'Drug Name', 'Cost per Day (RM)', 'Yearly Cost (RM)', 'Status']];
            const emptySheet = XLSX.utils.aoa_to_sheet(emptyData);
            XLSX.utils.book_append_sheet(wb, emptySheet, 'Enrollments');
          }

          filename = `yearly_costs_${dayjs().format('YYYY-MM-DD')}.xlsx`;
          break;

        case 'cost_analysis':
          if (!reportData.costAnalysis || reportData.costAnalysis.length === 0) {
            message.warning('Please generate the report first');
            return;
          }

          const costAnalysisData = reportData.costAnalysis.map(record => ({
            'Department': record.department_name?.includes(' - ')
              ? record.department_name.split(' - ')[1]
              : (record.department_name || '-'),
            'Drug Name': record.drug_name || '-',
            'Patient Count': record.patient_count || 0,
            'Total Annual Cost (RM)': record.total_annual_cost
              ? Number(record.total_annual_cost).toFixed(2)
              : '0.00',
            'Avg Cost per Patient (RM)': record.avg_cost_per_patient
              ? Number(record.avg_cost_per_patient).toFixed(2)
              : '0.00',
            'Unit Price (RM)': record.unit_price
              ? Number(record.unit_price).toFixed(2)
              : '0.00'
          }));

          // Add metadata sheet
          const costAnalysisMeta = [
            ['Report Type', 'Cost Analysis Report'],
            ['Export Date', dayjs().format('DD/MM/YYYY HH:mm:ss')],
            ['Date Range', selectedDateRange[0] && selectedDateRange[1]
              ? `${selectedDateRange[0].format('DD/MM/YYYY')} - ${selectedDateRange[1].format('DD/MM/YYYY')}`
              : 'All Time'],
            ['Department Filter', selectedDepartment !== 'all'
              ? departments.find(d => d.id.toString() === selectedDepartment)?.name || 'All'
              : 'All Departments'],
            ['Total Records', reportData.costAnalysis.length]
          ];
          const costAnalysisMetaSheet = XLSX.utils.aoa_to_sheet(costAnalysisMeta);
          XLSX.utils.book_append_sheet(wb, costAnalysisMetaSheet, 'Report Info');

          const costAnalysisSheet = XLSX.utils.json_to_sheet(costAnalysisData);
          XLSX.utils.book_append_sheet(wb, costAnalysisSheet, 'Cost Analysis');
          filename = `cost_analysis_${dayjs().format('YYYY-MM-DD')}.xlsx`;
          break;

        case 'quota_utilization':
          if (!reportData.quotaUtilization || reportData.quotaUtilization.length === 0) {
            message.warning('Please generate the report first');
            return;
          }

          const quotaData = reportData.quotaUtilization.map(record => ({
            'Department': record.department_name?.includes(' - ')
              ? record.department_name.split(' - ')[1]
              : (record.department_name || '-'),
            'Drug Name': record.drug_name || '-',
            'Quota': record.quota_number || 0,
            'Active Patients': record.active_patients || 0,
            'Available Slots': record.available_slots || 0,
            'Utilization %': record.utilization_percentage
              ? `${record.utilization_percentage}%`
              : '0%',
            'Status': record.status || '-'
          }));

          // Add metadata sheet
          const quotaMeta = [
            ['Report Type', 'Quota Utilization Report'],
            ['Export Date', dayjs().format('DD/MM/YYYY HH:mm:ss')],
            ['Department Filter', selectedDepartment !== 'all'
              ? departments.find(d => d.id.toString() === selectedDepartment)?.name || 'All'
              : 'All Departments'],
            ['Total Records', reportData.quotaUtilization.length]
          ];
          const quotaMetaSheet = XLSX.utils.aoa_to_sheet(quotaMeta);
          XLSX.utils.book_append_sheet(wb, quotaMetaSheet, 'Report Info');

          const quotaSheet = XLSX.utils.json_to_sheet(quotaData);
          XLSX.utils.book_append_sheet(wb, quotaSheet, 'Quota Utilization');
          filename = `quota_utilization_${dayjs().format('YYYY-MM-DD')}.xlsx`;
          break;

        case 'defaulters':
          if (!reportData.defaulters || reportData.defaulters.length === 0) {
            message.warning('Please generate the report first');
            return;
          }

          const defaultersData = reportData.defaulters.map(record => ({
            'Department': record.department_name?.includes(' - ')
              ? record.department_name.split(' - ')[1]
              : (record.department_name || '-'),
            'Drug Name': record.drug_name || '-',
            'Patient Name': record.patient_name || '-',
            'IC Number': record.ic_number || '-',
            'Last Refill': record.latest_refill_date
              ? dayjs(record.latest_refill_date).format('DD/MM/YYYY')
              : 'Never',
            'Days Since Refill': record.days_since_refill || 0,
            'SPUB': record.spub ? 'Yes' : 'No'
          }));

          // Add metadata sheet
          const defaultersMeta = [
            ['Report Type', 'Defaulter Report'],
            ['Export Date', dayjs().format('DD/MM/YYYY HH:mm:ss')],
            ['Department Filter', selectedDepartment !== 'all'
              ? departments.find(d => d.id.toString() === selectedDepartment)?.name || 'All'
              : 'All Departments'],
            ['Total Defaulters', reportData.defaulters.length],
            ['Note', 'Patients with no refill for more than 6 months (excluding SPUB patients)']
          ];
          const defaultersMetaSheet = XLSX.utils.aoa_to_sheet(defaultersMeta);
          XLSX.utils.book_append_sheet(wb, defaultersMetaSheet, 'Report Info');

          const defaultersSheet = XLSX.utils.json_to_sheet(defaultersData);
          XLSX.utils.book_append_sheet(wb, defaultersSheet, 'Defaulters');
          filename = `defaulters_${dayjs().format('YYYY-MM-DD')}.xlsx`;
          break;

        case 'all_enrollments':
          // Fetch all enrollments if not already available
          try {
            setLoading(true);
            const params = {
              department_id: selectedDepartment !== 'all' ? selectedDepartment : undefined
            };
            const response = await enrollmentsAPI.getAll(params);
            const allEnrollments = response.data;

            if (!allEnrollments || allEnrollments.length === 0) {
              message.warning('No enrollments found');
              setLoading(false);
              return;
            }

            const enrollmentsData = allEnrollments.map(record => ({
              'Patient Name': record.patient_name || '-',
              'IC Number': record.ic_number || '-',
              'Department': record.department_name?.includes(' - ')
                ? record.department_name.split(' - ')[1]
                : (record.department_name || '-'),
              'Drug Name': record.drug_name || '-',
              'Dose per Day': record.dose_per_day || '-',
              'Cost per Day (RM)': record.cost_per_day ? parseFloat(record.cost_per_day).toFixed(2) : '-',
              'Start Date': record.prescription_start_date
                ? dayjs(record.prescription_start_date).format('DD/MM/YYYY')
                : '-',
              'End Date': record.prescription_end_date
                ? dayjs(record.prescription_end_date).format('DD/MM/YYYY')
                : '-',
              'Last Refill Date': record.latest_refill_date
                ? dayjs(record.latest_refill_date).format('DD/MM/YYYY')
                : '-',
              'SPUB': record.spub ? 'Yes' : 'No',
              'Status': record.is_active ? 'Active' : 'Inactive',
              'Remarks': record.remarks || '-'
            }));

            // Add metadata sheet
            const allEnrollmentsMeta = [
              ['Report Type', 'All Enrollments Report'],
              ['Export Date', dayjs().format('DD/MM/YYYY HH:mm:ss')],
              ['Department Filter', selectedDepartment !== 'all'
                ? departments.find(d => d.id.toString() === selectedDepartment)?.name || 'All'
                : 'All Departments'],
              ['Total Enrollments', allEnrollments.length],
              ['Active Enrollments', allEnrollments.filter(e => e.is_active).length],
              ['Inactive Enrollments', allEnrollments.filter(e => !e.is_active).length]
            ];
            const allEnrollmentsMetaSheet = XLSX.utils.aoa_to_sheet(allEnrollmentsMeta);
            XLSX.utils.book_append_sheet(wb, allEnrollmentsMetaSheet, 'Report Info');

            const allEnrollmentsSheet = XLSX.utils.json_to_sheet(enrollmentsData);
            XLSX.utils.book_append_sheet(wb, allEnrollmentsSheet, 'All Enrollments');
            filename = `all_enrollments_${dayjs().format('YYYY-MM-DD')}.xlsx`;
            setLoading(false);
          } catch (error) {
            setLoading(false);
            message.error('Error fetching enrollments');
            console.error('Error:', error);
            return;
          }
          break;

        default:
          message.error('Unknown report type');
          return;
      }

      // Write and download
      XLSX.writeFile(wb, filename);
      message.success('Report exported successfully');
    } catch (error) {
      console.error('Export error:', error);
      message.error('Error exporting report');
    }
  };

  const costAnalysisColumns = [
    {
      title: 'Department',
      dataIndex: 'department_name',
      key: 'department_name',
      render: (value) => (value && value.includes(' - ') ? value.split(' - ')[1] : (value || '-')),
    },
    {
      title: 'Drug Name',
      dataIndex: 'drug_name',
      key: 'drug_name',
    },
    {
      title: 'Patient Count',
      dataIndex: 'patient_count',
      key: 'patient_count',
    },
    {
      title: 'Total Annual Cost',
      dataIndex: 'total_annual_cost',
      key: 'total_annual_cost',
      render: (value) => `RM ${Number(value || 0).toLocaleString('en-MY', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,

    },
    {
      title: 'Avg Cost per Patient',
      dataIndex: 'avg_cost_per_patient',
      key: 'avg_cost_per_patient',
      render: (value) => `RM ${Number(value || 0).toLocaleString('en-MY', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,

    },
    {
      title: 'Unit Price',
      dataIndex: 'unit_price',
      key: 'unit_price',
      render: (value) => `RM ${value ? Number(value).toFixed(2) : '0.00'}`,
    },
  ];

  const quotaUtilizationColumns = [
    {
      title: 'Department',
      dataIndex: 'department_name',
      align: 'center',
      key: 'department_name',
      width: 120,
      render: (value) =>
        value && value.includes(' - ')
          ? value.split(' - ')[1]
          : (value || '-'),
    },
    {
      title: 'Drug Name',
      dataIndex: 'drug_name',
      key: 'drug_name',
      width: 180,
    },
    {
      title: 'Quota',
      dataIndex: 'quota_number',
      align: 'center',
      key: 'quota_number',
      width: 60,
    },
    {
      title: 'Active Patients',
      dataIndex: 'active_patients',
      align: 'center',
      key: 'active_patients',
      width: 60,
    },
    {
      title: 'Available Slots',
      dataIndex: 'available_slots',
      align: 'center',
      key: 'available_slots',
      width: 60,
    },
    {
      title: 'Utilization %',
      dataIndex: 'utilization_percentage',
      key: 'utilization_percentage',
      align: 'center',
      width: 120,
      render: (value) => {
        const percentage = value || 0;
        let color = '#52c41a';
        if (percentage >= 90) color = '#ff4d4f';
        else if (percentage >= 75) color = '#faad14';

        return (
          <Progress
            percent={percentage}
            strokeColor={color}
            format={(percent) => (
              <span style={{ fontSize: '12px', color }}>{percent}%</span>
            )}
          />
        );
      },
    },
    {
      title: 'Status',
      dataIndex: 'status',
      align: 'center',
      key: 'status',
      width: 80,
      render: (status) => {
        const color =
          {
            FULL: 'red',
            HIGH: 'orange',
            MEDIUM: 'blue',
            LOW: 'green',
          }[status] || 'default';
        return <span style={{ color }}>{status}</span>;
      },
    },
  ];

  const defaultersColumns = [
    {
      title: 'Department',
      dataIndex: 'department_name',
      key: 'department_name',
      render: (value) => (value && value.includes(' - ') ? value.split(' - ')[1] : (value || '-')),
    },
    {
      title: 'Drug Name',
      dataIndex: 'drug_name',
      key: 'drug_name',
    },
    {
      title: 'Patient Name',
      dataIndex: 'patient_name',
      key: 'patient_name',
    },
    {
      title: 'IC Number',
      dataIndex: 'ic_number',
      key: 'ic_number',
    },
    {
      title: 'Last Refill',
      dataIndex: 'latest_refill_date',
      key: 'latest_refill_date',
      render: (date) => date ? dayjs(date).format('DD/MM/YYYY') : 'Never',
    },
    {
      title: 'Days Since Refill',
      dataIndex: 'days_since_refill',
      key: 'days_since_refill',
      render: (days) => <span style={{ color: days > 180 ? 'red' : 'orange' }}>{days}</span>,
    },
    {
      title: 'SPUB',
      dataIndex: 'spub',
      key: 'spub',
      render: (spub) => spub ? 'Yes' : 'No',
    },
  ];

  const yearlyCostColumns = [
    {
      title: 'Patient Name',
      dataIndex: 'patient_name',
      key: 'patient_name',
      sorter: (a, b) => (a.patient_name || '').localeCompare(b.patient_name || ''),
    },
    {
      title: 'IC Number',
      dataIndex: 'ic_number',
      key: 'ic_number',
    },
    {
      title: 'Department',
      dataIndex: 'department_name',
      key: 'department_name',
      render: (value) => (value && value.includes(' - ') ? value.split(' - ')[1] : (value || '-')),
    },
    {
      title: 'Drug Name',
      dataIndex: 'drug_name',
      key: 'drug_name',
      sorter: (a, b) => (a.drug_name || '').localeCompare(b.drug_name || ''),
      // --- Search Filter for Drug Name ---
      filterDropdown: ({ setSelectedKeys, selectedKeys, confirm, clearFilters }) => (
        <div style={{ padding: 8 }} onKeyDown={(e) => e.stopPropagation()}>
          <Input
            placeholder="Search drug"
            value={selectedKeys[0]}
            onChange={e => setSelectedKeys(e.target.value ? [e.target.value] : [])}
            onPressEnter={() => confirm()}
            style={{ marginBottom: 8, display: 'block' }}
          />
          <Space>
            <Button
              type="primary"
              onClick={() => confirm()}
              icon={<SearchOutlined />}
              size="small"
            >
              Search
            </Button>
            <Button onClick={() => {
              clearFilters();
              setSelectedKeys([]);
            }}
              size="small"
            >
              Reset
            </Button>
          </Space>
        </div>
      ),
      filterIcon: filtered => <SearchOutlined style={{ color: filtered ? '#1890ff' : undefined }} />,
      onFilter: (value, record) =>
        record.drug_name
          ? record.drug_name.toString().toLowerCase().includes(value.toLowerCase())
          : false,
    },
    {
      title: 'Cost per Day',
      dataIndex: 'cost_per_day',
      key: 'cost_per_day',
      render: (value) => `RM ${Number(value || 0).toLocaleString('en-MY', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,
      sorter: (a, b) => (Number(a.cost_per_day) || 0) - (Number(b.cost_per_day) || 0),
    },
    {
      title: 'Yearly Cost',
      dataIndex: 'calculated_yearly_cost',
      key: 'calculated_yearly_cost',
      render: (value) => `RM ${Number(value || 0).toLocaleString('en-MY', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,
      sorter: (a, b) => (Number(a.calculated_yearly_cost) || 0) - (Number(b.calculated_yearly_cost) || 0),
    },
    {
      title: 'Status',
      dataIndex: 'is_active',
      key: 'is_active',
      filters: [
        { text: 'Active', value: true },
        { text: 'Inactive', value: false },
      ],
      onFilter: (value, record) => record.is_active === value,
      render: (isActive) => (
        <span style={{ color: isActive ? 'green' : 'red' }}>
          {isActive ? 'Active' : 'Inactive'}
        </span>
      ),
    },
  ];

  return (
    <div style={{ padding: '24px' }}>
      <Card style={{ marginBottom: '24px' }}>
        <Title level={3} style={{ marginBottom: '16px' }}>
          <FileTextOutlined style={{ marginRight: '8px' }} />
          Reports & Analytics
        </Title>

        <Row gutter={16} style={{ marginBottom: '16px' }}>
          <Col xs={24} sm={8} md={6}>
            <Select
              style={{ width: '100%' }}
              placeholder="Select Department"
              value={selectedDepartment}
              onChange={setSelectedDepartment}
            >
              <Option value="all">All Departments</Option>
              {departments.map(dept => (
                <Option key={dept.id} value={dept.id.toString()}>
                  {dept.name && dept.name.includes(' - ') ? dept.name.split(' - ')[1] : (dept.name || '-')}
                </Option>
              ))}
            </Select>
          </Col>
        </Row>

        {dashboardData && (
          <Row gutter={16} style={{ marginBottom: '24px' }}>
            <Col xs={12} sm={6} style={{ textAlign: 'center' }}>
              <Statistic
                title="Total Departments"
                value={dashboardData.total_departments}
                valueStyle={{ color: '#1890ff' }}
              />
            </Col>
            <Col xs={12} sm={6} style={{ textAlign: 'center' }}>
              <Statistic
                title="Total Drugs"
                value={dashboardData.total_drugs}
                valueStyle={{ color: '#52c41a' }}
              />
            </Col>
            <Col xs={12} sm={6} style={{ textAlign: 'center' }}>
              <Statistic
                title="Active Enrollments"
                value={dashboardData.active_enrollments}
                valueStyle={{ color: '#faad14' }}
              />
            </Col>
            <Col xs={12} sm={6} style={{ textAlign: 'center' }}>
              <Statistic
                title="Potential Defaulters"
                value={dashboardData.potential_defaulters}
                valueStyle={{ color: '#f5222d' }}
              />
            </Col>
          </Row>
        )}
      </Card>

      <Tabs
        defaultActiveKey="yearly-costs"
        items={[
          {
            key: 'yearly-costs',
            label: 'Yearly Cost Report',
            children: (
              <Card>
                <Row justify="space-between" align="middle" style={{ marginBottom: '16px' }}>
                  <Col>
                    <Title level={4} style={{ margin: 0 }}>
                      <DollarOutlined style={{ marginRight: '8px' }} />
                      Annual Cost Report
                    </Title>
                    <Text type="secondary">
                      Shows projected annual cost report for active enrollment for each department
                    </Text>
                  </Col>
                  <Col>
                    <Space>
                      <Button onClick={fetchYearlyCosts} loading={loading} type="primary">
                        Generate Report
                      </Button>
                      <Button
                        icon={<FaFileExcel style={{ fontSize: '16px' }} />}
                        onClick={() => handleExport('yearly_costs')}
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
                        Export Excel
                      </Button>
                    </Space>
                  </Col>
                </Row>

                {yearlyCostData && (
                  <>
                    {/* Summary Statistics */}
                    <Row gutter={16} style={{ marginBottom: '24px' }}>
                      <Col xs={12} sm={6}>
                        <div style={{ textAlign: 'left' }}>
                          <div style={{ color: 'rgba(0, 0, 0, 0.45)', fontSize: '14px', marginBottom: '4px' }}>Total Annual Cost</div>
                          <div style={{ color: '#1890ff', fontSize: '20px', fontWeight: 600 }}>
                            RM <CountUp
                              end={yearlyCostData.summary.totalCost}
                              duration={2.5}
                              decimals={2}
                              separator=","
                            />
                          </div>
                        </div>
                      </Col>
                      <Col xs={12} sm={6}>
                        <div style={{ textAlign: 'left' }}>
                          <div style={{ color: 'rgba(0, 0, 0, 0.45)', fontSize: '14px', marginBottom: '4px' }}>Total Enrollments</div>
                          <div style={{ color: '#52c41a', fontSize: '24px', fontWeight: 600 }}>
                            <CountUp
                              end={yearlyCostData.summary.totalEnrollments}
                              duration={2}
                              separator=","
                            />
                          </div>
                        </div>
                      </Col>
                      <Col xs={12} sm={6}>
                        <div style={{ textAlign: 'left' }}>
                          <div style={{ color: 'rgba(0, 0, 0, 0.45)', fontSize: '14px', marginBottom: '4px' }}>Active Enrollments</div>
                          <div style={{ color: '#faad14', fontSize: '24px', fontWeight: 600 }}>
                            <CountUp
                              end={yearlyCostData.summary.activeEnrollments}
                              duration={2}
                              separator=","
                            />
                          </div>
                        </div>
                      </Col>
                      <Col xs={12} sm={6}>
                        <div style={{ textAlign: 'left' }}>
                          <div style={{ color: 'rgba(0, 0, 0, 0.45)', fontSize: '14px', marginBottom: '4px' }}>Avg Cost per Active Enrollment</div>
                          <div style={{ color: '#722ed1', fontSize: '24px', fontWeight: 600 }}>
                            RM <CountUp
                              end={yearlyCostData.summary.averageCostPerEnrollment}
                              duration={2.5}
                              decimals={2}
                              separator=","
                            />
                          </div>
                        </div>
                      </Col>
                    </Row>

                    {/* Department Totals */}
                    <Card size="small" style={{ marginBottom: '16px' }}>
                      <Title level={5}>Department Totals</Title>
                      <Row gutter={16}>
                        {Object.entries(yearlyCostData.departmentTotals).map(([dept, data]) => {
                          const deptColor = getDepartmentColor(dept);
                          return (
                            <Col xs={12} sm={8} md={6} key={dept.includes(' - ') ? dept.split(' - ')[1] : (dept || '-')} style={{ marginBottom: '12px' }}>
                              <Card
                                size="small"
                                className="department-card"
                                style={{
                                  '--dept-color': deptColor,
                                  borderLeft: `6px solid ${deptColor}`
                                }}
                                bodyStyle={{ padding: '12px' }}
                              >
                                <div style={{ lineHeight: '1.4' }}>
                                  <div className="department-header" style={{ color: 'rgba(0, 0, 0, 0.45)', fontSize: '14px', marginBottom: '4px' }}>
                                    <span className="department-name">{dept.includes(' - ') ? dept.split(' - ')[1] : (dept || '-')}</span>
                                  </div>
                                  <div style={{ fontSize: '16px', fontWeight: 600, color: '#000' }}>
                                    RM <CountUp
                                      end={data.total}
                                      duration={2}
                                      decimals={2}
                                      separator=","
                                    />
                                  </div>
                                  <div style={{ fontSize: '12px', color: '#666', marginTop: '4px' }}>
                                    <CountUp
                                      end={data.count}
                                      duration={1.5}
                                      separator=","
                                    /> enrollments
                                  </div>
                                </div>
                              </Card>
                            </Col>
                          );
                        })}
                      </Row>
                    </Card>

                    {/* Help Message */}
                    {yearlyCostData.summary.totalCost === 0 && (
                      <Alert
                        message="No Manual Costs Entered"
                        description="To see cost data in this report, please enter 'Cost per Day' values in the enrollment forms. Only active enrollments with manual cost per day input will be included in cost calculations."
                        type="info"
                        showIcon
                        style={{ marginBottom: '16px' }}
                      />
                    )}

                    {/* Detailed Table */}
                    <Table
                      columns={yearlyCostColumns}
                      dataSource={yearlyCostData.enrollments}
                      rowKey={(record, index) => `${record.patient_name}-${record.drug_name}-${index}`}
                      pagination={{
                        defaultPageSize: 10,
                        showSizeChanger: true,
                        showQuickJumper: true,
                        showTotal: (total, range) => `${range[0]}-${range[1]} of ${total} records`,
                        pageSizeOptions: ['5', '10', '20', '50', '100'],
                        showLessItems: false
                      }}

                      scroll={{ x: 1000 }}
                    />
                  </>
                )}
              </Card>
            )
          },

          {
            key: 'cost-analysis',
            label: 'Cost Analysis',
            children: (
              <Card>
                <Row justify="space-between" align="middle" style={{ marginBottom: '16px' }}>
                  <Col>
                    <Title level={4} style={{ margin: 0 }}>
                      <DollarOutlined style={{ marginRight: '8px' }} />
                      Cost Analysis Report
                    </Title>
                    <Text type="secondary">
                      Shows cost breakdown by department and drug for active enrollments with manual cost per day input
                    </Text>
                  </Col>
                  <Col>
                    <Space>
                      <Button onClick={fetchCostAnalysis} loading={loading} type="primary">
                        Generate Report
                      </Button>
                      <Button
                        icon={<FaFileExcel style={{ fontSize: '16px' }} />}
                        onClick={() => handleExport('cost_analysis')}
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
                        Export Excel
                      </Button>
                    </Space>
                  </Col>
                </Row>

                {reportData.costAnalysis && (
                  <>
                    <Table
                      columns={costAnalysisColumns}
                      dataSource={reportData.costAnalysis}
                      rowKey={(record, index) => `${record.department_name}-${record.drug_name}-${index}`}
                      pagination={{
                        defaultPageSize: 10,
                        showSizeChanger: true,
                        showQuickJumper: true,
                        showTotal: (total, range) => `${range[0]}-${range[1]} of ${total} records`,
                        pageSizeOptions: ['5', '10', '20', '50', '100'],
                        showLessItems: false
                      }}
                      scroll={{ x: 800 }}
                    />
                  </>
                )}
              </Card>
            )
          },
          {
            key: 'quota-utilization',
            label: 'Quota Utilization',
            children: (
              <Card>
                <Row justify="space-between" align="middle" style={{ marginBottom: '16px' }}>
                  <Col>
                    <Title level={4} style={{ margin: 0 }}>
                      <BarChartOutlined style={{ marginRight: '8px' }} />
                      Quota Utilization Report
                    </Title>
                    <Text type="secondary">
                      Shows quota utilization by department and drug for active enrollments
                    </Text>
                  </Col>
                  <Col>
                    <Space>
                      <Button onClick={fetchQuotaUtilization} loading={loading} type="primary">
                        Generate Report
                      </Button>
                      <Button
                        icon={<FaFileExcel style={{ fontSize: '16px' }} />}
                        onClick={() => handleExport('quota_utilization')}
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
                        Export Excel
                      </Button>
                    </Space>
                  </Col>
                </Row>

                {reportData.quotaUtilization && (
                  <Table
                    columns={quotaUtilizationColumns}
                    dataSource={reportData.quotaUtilization}
                    rowKey={(record, index) => `${record.department_name}-${record.drug_name}-${index}`}
                    pagination={{
                      defaultPageSize: 10,
                      showSizeChanger: true,
                      showQuickJumper: true,
                      showTotal: (total, range) => `${range[0]}-${range[1]} of ${total} records`,
                      pageSizeOptions: ['5', '10', '20', '50', '100'],
                      showLessItems: false
                    }}

                    scroll={{ x: 800 }}
                  />
                )}
              </Card>
            )
          },
          {
            key: 'defaulters',
            label: 'Defaulters',
            children: (
              <Card>
                <Row justify="space-between" align="middle" style={{ marginBottom: '16px' }}>
                  <Col>
                    <Title level={4} style={{ margin: 0 }}>
                      <WarningOutlined style={{ marginRight: '8px' }} />
                      Defaulter Report
                    </Title>
                    <Text type="secondary">
                      Shows patients who haven't had a refill for more than 6 months (excluding SPUB patients)
                    </Text>
                  </Col>
                  <Col>
                    <Space>
                      <Button onClick={fetchDefaulters} loading={loading} type="primary">
                        Generate Report
                      </Button>
                      <Button
                        icon={<FaFileExcel style={{ fontSize: '16px' }} />}
                        onClick={() => handleExport('defaulters')}
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
                        Export Excel
                      </Button>
                    </Space>
                  </Col>
                </Row>

                {reportData.defaulters && (
                  <>
                    <Alert
                      message={`Found ${reportData.defaulters.length} potential defaulters`}
                      description="Patients with no refill for more than 6 months (excluding SPUB patients)"
                      type="warning"
                      showIcon
                      style={{ marginBottom: '16px' }}
                    />
                    <Table
                      columns={defaultersColumns}
                      dataSource={reportData.defaulters}
                      rowKey={(record, index) => `${record.patient_name}-${record.drug_name}-${index}`}
                      pagination={{
                        defaultPageSize: 10,
                        showSizeChanger: true,
                        showQuickJumper: true,
                        showTotal: (total, range) => `${range[0]}-${range[1]} of ${total} records`,
                        pageSizeOptions: ['5', '10', '20', '50', '100'],
                        showLessItems: false
                      }}

                      scroll={{ x: 800 }}
                    />
                  </>
                )}
              </Card>
            )
          },
          {
            key: 'export-all',
            label: 'Export All Data',
            children: (
              <Card>
                <Title level={4} style={{ marginBottom: '16px' }}>
                  <DownloadOutlined style={{ marginRight: '8px' }} />
                  Export All Data
                </Title>
                <Row gutter={16}>
                  <Col xs={24} sm={8}>
                    <Button
                      block
                      size="large"
                      onClick={() => handleExport('all_enrollments')}
                      icon={<UserOutlined />}
                    >
                      Export All Enrollments
                    </Button>
                  </Col>
                  <Col xs={24} sm={8}>
                    <Button
                      block
                      size="large"
                      onClick={() => handleExport('cost_analysis')}
                      icon={<DollarOutlined />}
                    >
                      Export Cost Analysis
                    </Button>
                  </Col>
                  <Col xs={24} sm={8}>
                    <Button
                      block
                      size="large"
                      onClick={() => handleExport('quota_utilization')}
                      icon={<MedicineBoxOutlined />}
                    >
                      Export Quota Utilization
                    </Button>
                  </Col>
                </Row>
              </Card>
            )
          }
        ]}
      />
    </div>
  );
};

export default ReportsPage;
