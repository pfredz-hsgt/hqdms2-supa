import React from 'react';
import { Breadcrumb } from 'antd';
import { HomeOutlined } from '@ant-design/icons';
import { Link, useLocation } from 'react-router-dom';

const BreadcrumbNav = () => {
    const location = useLocation();
    const pathSnippets = location.pathname.split('/').filter(i => i);

    // Define route names
    const routeNames = {
        '': 'Home',
        'refill': 'Quick Refill',
        'enrollments': 'Enrollments',
        'drugs': 'Drug List',
        'patients': 'Patient List',
        'departments': 'Departments',
        'reports': 'Reports',
        'prescriber-overview': 'Prescriber Overview',
        'settings': 'Settings'
    };

    const breadcrumbItems = [
        {
            title: (
                <Link to="/">
                    <HomeOutlined style={{ marginRight: '4px' }} />
                    Home
                </Link>
            ),
        },
    ];

    pathSnippets.forEach((snippet, index) => {
        const url = `/${pathSnippets.slice(0, index + 1).join('/')}`;
        const isLast = index === pathSnippets.length - 1;

        breadcrumbItems.push({
            title: isLast ? (
                <span>{routeNames[snippet] || snippet}</span>
            ) : (
                <Link to={url}>{routeNames[snippet] || snippet}</Link>
            ),
        });
    });

    // Don't show breadcrumb on home page or login
    if (pathSnippets.length === 0 || location.pathname === '/login') {
        return null;
    }

    return (
        <div style={{
            marginBottom: '16px',
            padding: '12px 16px',
            background: 'var(--bg-primary)',
            borderRadius: 'var(--radius-md)',
            boxShadow: 'var(--shadow-sm)'
        }}>
            <Breadcrumb items={breadcrumbItems} />
        </div>
    );
};

export default BreadcrumbNav;
