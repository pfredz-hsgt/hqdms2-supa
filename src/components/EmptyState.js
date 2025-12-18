import React from 'react';
import { Button } from 'antd';
import { InboxOutlined, FileTextOutlined, MedicineBoxOutlined, UserOutlined } from '@ant-design/icons';
import '../styles/animations.css';

const EmptyState = ({
    type = 'default',
    title,
    description,
    actionText,
    onAction
}) => {
    const getIcon = () => {
        switch (type) {
            case 'drugs':
                return <MedicineBoxOutlined className="empty-state-icon" />;
            case 'patients':
                return <UserOutlined className="empty-state-icon" />;
            case 'reports':
                return <FileTextOutlined className="empty-state-icon" />;
            default:
                return <InboxOutlined className="empty-state-icon" />;
        }
    };

    const getDefaultTitle = () => {
        switch (type) {
            case 'drugs':
                return 'No Drugs Found';
            case 'patients':
                return 'No Patients Found';
            case 'reports':
                return 'No Reports Available';
            default:
                return 'No Data Available';
        }
    };

    const getDefaultDescription = () => {
        switch (type) {
            case 'drugs':
                return 'Start by adding your first quota drug to the system.';
            case 'patients':
                return 'No patients match your search criteria. Try adjusting your filters.';
            case 'reports':
                return 'Generate your first report to see insights here.';
            default:
                return 'There is no data to display at the moment.';
        }
    };

    return (
        <div className="empty-state">
            {getIcon()}
            <h3 className="empty-state-title">
                {title || getDefaultTitle()}
            </h3>
            <p className="empty-state-description">
                {description || getDefaultDescription()}
            </p>
            {actionText && onAction && (
                <div className="empty-state-action">
                    <Button type="primary" size="large" onClick={onAction}>
                        {actionText}
                    </Button>
                </div>
            )}
        </div>
    );
};

export default EmptyState;
