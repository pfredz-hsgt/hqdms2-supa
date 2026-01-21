import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Button,
  Typography,
  Space,
  Modal,
  Form,
  Input,
  message,
  Popconfirm,
  Tag,
  Tooltip,
  Row,
  Col
} from 'antd';
import {
  PlusOutlined,
  DeleteOutlined,
  BankOutlined,
  MedicineBoxOutlined,
  UserOutlined
} from '@ant-design/icons';
import { departmentsAPI } from '../services/api';
import { useSettings } from '../contexts/SettingsContext';

const { Title } = Typography;

const DepartmentListPage = () => {
  const { settings, loading: settingsLoading } = useSettings();
  const [departments, setDepartments] = useState([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingDepartment, setEditingDepartment] = useState(null);
  const [form] = Form.useForm();

  useEffect(() => {
    fetchDepartments();
  }, []);

  const fetchDepartments = async () => {
    setLoading(true);
    try {
      const response = await departmentsAPI.getAll();
      setDepartments(response.data);
    } catch (error) {
      message.error('Error fetching departments');
      console.error('Fetch error:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAdd = () => {
    setEditingDepartment(null);
    form.resetFields();
    setModalVisible(true);
  };

  const handleEdit = (department) => {
    setEditingDepartment(department);
    form.setFieldsValue(department);
    setModalVisible(true);
  };

  const handleDelete = async (id) => {
    try {
      await departmentsAPI.delete(id);
      message.success('Department deleted successfully');
      fetchDepartments();
      setModalVisible(false);
    } catch (error) {
      message.error('Error deleting department');
      console.error('Delete error:', error);
    }
  };

  const handleSubmit = async (values) => {
    try {
      if (editingDepartment) {
        await departmentsAPI.update(editingDepartment.id, values);
        message.success('Department updated successfully');
      } else {
        await departmentsAPI.create(values);
        message.success('Department created successfully');
      }
      setModalVisible(false);
      form.resetFields();
      fetchDepartments();
    } catch (error) {
      message.error(editingDepartment ? 'Error updating department' : 'Error creating department');
      console.error('Submit error:', error);
    }
  };

  const columns = [
    {
      title: 'Department Name',
      dataIndex: 'name',
      key: 'name',
      render: (name) => (
        <Space>
          <BankOutlined />
          <span style={{ fontWeight: 'bold' }}>{name && name.includes(' - ') ? name.split(' - ')[1] : (name || '-')}</span>
        </Space>
      ),
    },
    {
      title: 'Drug Count',
      dataIndex: 'drug_count',
      key: 'drug_count',
      render: (count) => (
        <Tag color="blue">
          <MedicineBoxOutlined style={{ marginRight: '4px', fontSize: 'inherit' }} />
          {count || 0} drugs
        </Tag>
      ),
    },
    {
      title: 'Total Enrollments',
      dataIndex: 'total_enrollments',
      key: 'total_enrollments',
      render: (count) => (
        <Tag color="green">
          <UserOutlined style={{ marginRight: '4px', fontSize: 'inherit' }} />
          {count || 0} patients
        </Tag>
      ),
    },
  ];



  return (
    <div>
      <Card>
        <div style={{ marginBottom: '24px', marginTop: '24px' }}>
          <Row justify="space-between" align="middle" style={{ marginBottom: '16px' }}>
            <Col>
              <Title level={3} style={{ margin: 0 }}>
                <BankOutlined style={{ marginRight: '8px' }} />
                Department Management
              </Title>
            </Col>
            <Col>
              <Button
                type="primary"
                icon={<PlusOutlined />}
                onClick={handleAdd}
                disabled={settingsLoading || !settings?.allowNewDepartments}
                title={settingsLoading || !settings?.allowNewDepartments ? "Adding new department is disabled by admin" : "Add new deparment"}
              >
                Add Department
              </Button>
            </Col>
          </Row>

        </div>

        <Table
          columns={columns}
          dataSource={departments}
          rowKey="id"
          loading={loading}
          pagination={{
            defaultPageSize: 20,
            showSizeChanger: true,
            showQuickJumper: true,
            pageSizeOptions: ['5', '10', '20', '50', '100'],
            showLessItems: false
          }}
          scroll={{ x: 600 }}
          onRow={(department) => ({
            onClick: () => handleEdit(department),
            style: { cursor: 'pointer' }
          })}

        />
      </Card>

      {/* Add/Edit Department Modal */}
      <Modal
        title={editingDepartment ? 'Edit Department' : 'Add New Department'}
        open={modalVisible}
        onCancel={() => {
          setModalVisible(false);
          form.resetFields();
        }}
        footer={null}
        width={500}
        centered
      >
        <Form
          form={form}
          layout="vertical"
          onFinish={handleSubmit}
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
              {editingDepartment ?
                <Popconfirm
                  title="Are you sure you want to delete this department?"
                  description="This will also delete all associated drugs and enrollments."
                  onConfirm={() => handleDelete(editingDepartment.id)}
                  okText="Yes"
                  cancelText="No"
                >
                  <Tooltip title="Delete">
                    <Button
                      icon={<DeleteOutlined />}
                      danger
                      disabled={settingsLoading || !settings?.allowNewDepartments}
                      title={settingsLoading || !settings?.allowNewDepartments ? "Deleting department is disabled by admin" : "Delete deparment?"}

                    />
                  </Tooltip>
                </Popconfirm>
                : ' '}
              <Button onClick={() => setModalVisible(false)}>
                Cancel
              </Button>
              <Button
                type="primary"
                disabled={settingsLoading || !settings?.allowNewDepartments}
                title={settingsLoading || !settings?.allowNewDepartments ? "Editing department is disabled by admin" : "Update deparment"}
                htmlType="submit">
                {editingDepartment ? 'Update' : 'Create'}

              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default DepartmentListPage;
