import React, { useEffect, useState } from 'react';
import { api } from '../lib/api';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card';
import { Spinner } from '../components/ui/Spinner';
import { Users, Building, Banknote } from 'lucide-react';

interface SummaryData {
  total_employees: number;
  total_departments: number;
  departments: {
    name: string;
    employee_count: number;
    total_salary: number;
    currency: string;
  }[];
}

export function Dashboard() {
  const [summary, setSummary] = useState<SummaryData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      try {
        const response = await api.get<{ summary: SummaryData }>('/api/analytics/summary');
        setSummary(response.summary);
      } catch (error) {
        console.error('Failed to load summary', error);
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center items-center" style={{ height: '50vh' }}>
        <Spinner />
      </div>
    );
  }

  if (!summary) return <div>Failed to load data.</div>;

  return (
    <div className="dashboard">
      <div className="mb-6">
        <h1 className="text-xl">Dashboard Overview</h1>
        <p className="text-secondary">Summary of company-wide active employees and salaries.</p>
      </div>

      <div className="grid grid-cols-2 gap-6 mb-8">
        <Card>
          <CardContent className="flex items-center gap-4">
            <div className="p-4" style={{ backgroundColor: 'var(--brand-light)', color: 'var(--brand-primary)', borderRadius: '50%' }}>
              <Users size={24} />
            </div>
            <div>
              <p className="text-sm text-secondary font-medium">Total Active Employees</p>
              <h2 className="text-xl mt-1">{summary.total_employees}</h2>
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardContent className="flex items-center gap-4">
            <div className="p-4" style={{ backgroundColor: 'var(--success-bg)', color: 'var(--success)', borderRadius: '50%' }}>
              <Building size={24} />
            </div>
            <div>
              <p className="text-sm text-secondary font-medium">Total Departments</p>
              <h2 className="text-xl mt-1">{summary.total_departments}</h2>
            </div>
          </CardContent>
        </Card>
      </div>

      <h2 className="text-lg mb-4">Department Breakdown</h2>
      <div className="grid grid-cols-3 gap-6">
        {summary.departments.map((dept, idx) => (
          <Card key={idx}>
            <CardHeader>
              <CardTitle>{dept.name}</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex justify-between items-center mb-4">
                <span className="text-sm text-secondary">Employees</span>
                <span className="font-semibold">{dept.employee_count}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-secondary">Total Monthly Salary</span>
                <span className="font-semibold flex items-center gap-1">
                  <Banknote size={16} className="text-success" />
                  {new Intl.NumberFormat('en-US', { style: 'currency', currency: dept.currency }).format(dept.total_salary)}
                </span>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
