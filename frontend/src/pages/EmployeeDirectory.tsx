import React, { useEffect, useState, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../lib/api';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { Spinner } from '../components/ui/Spinner';
import { Search, ChevronLeft, ChevronRight } from 'lucide-react';
import './EmployeeDirectory.css';

interface Employee {
  id: number;
  employee_number: string;
  full_name: string;
  email: string;
  department: string;
  country: string;
  job_title: string;
  active: boolean;
  current_gross_salary?: number;
  currency: string;
}

interface Meta {
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
}

export function EmployeeDirectory() {
  const navigate = useNavigate();
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [meta, setMeta] = useState<Meta | null>(null);
  const [loading, setLoading] = useState(true);
  
  // Filters
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [searchInput, setSearchInput] = useState('');
  const [department, setDepartment] = useState('');
  const [country, setCountry] = useState('');

  const loadEmployees = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      params.append('page', page.toString());
      if (search) params.append('search', search);
      if (department) params.append('department', department);
      if (country) params.append('country', country);

      const response = await api.get<{ employees: Employee[], meta: Meta }>(`/api/employees?${params.toString()}`);
      setEmployees(response.employees);
      setMeta(response.meta);
    } catch (error) {
      console.error('Failed to load employees', error);
    } finally {
      setLoading(false);
    }
  }, [page, search, department, country]);

  useEffect(() => {
    loadEmployees();
  }, [loadEmployees]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSearch(searchInput);
    setPage(1);
  };

  const handleRowClick = (id: number) => {
    navigate(`/employees/${id}`);
  };

  const formatSalary = (amount: number | undefined, currency: string) => {
    if (amount === undefined || amount === null) return 'N/A';
    return new Intl.NumberFormat('en-US', { style: 'currency', currency }).format(amount);
  };

  return (
    <div className="directory-page">
      <div className="page-header mb-6">
        <div>
          <h1 className="text-xl">Employee Directory</h1>
          <p className="text-secondary">Manage and view all employee details.</p>
        </div>
      </div>

      <Card className="mb-6">
        <div className="filter-bar p-4 flex gap-4 items-center border-b border-[var(--border-color)]">
          <form onSubmit={handleSearchSubmit} className="search-form flex-1 relative">
            <Search size={18} className="search-icon absolute left-3 top-1/2 -translate-y-1/2 text-[var(--text-tertiary)]" />
            <input 
              type="text" 
              placeholder="Search by name, email, or employee #..." 
              className="search-input w-full pl-10 pr-4 py-2 border rounded-md"
              value={searchInput}
              onChange={(e) => setSearchInput(e.target.value)}
            />
          </form>
          
          <div className="filters flex gap-4">
            <select 
              className="filter-select border rounded-md px-3 py-2"
              value={department}
              onChange={(e) => { setDepartment(e.target.value); setPage(1); }}
            >
              <option value="">All Departments</option>
              <option value="Engineering">Engineering</option>
              <option value="Sales">Sales</option>
              <option value="Marketing">Marketing</option>
              <option value="HR">HR</option>
              <option value="Finance">Finance</option>
            </select>

            <select 
              className="filter-select border rounded-md px-3 py-2"
              value={country}
              onChange={(e) => { setCountry(e.target.value); setPage(1); }}
            >
              <option value="">All Countries</option>
              <option value="United States">United States</option>
              <option value="India">India</option>
              <option value="United Kingdom">United Kingdom</option>
              <option value="Canada">Canada</option>
              <option value="Germany">Germany</option>
            </select>
          </div>
        </div>

        {loading ? (
          <div className="flex justify-center items-center p-12">
            <Spinner />
          </div>
        ) : (
          <div className="table-container">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-[var(--bg-primary)] border-b border-[var(--border-color)]">
                  <th className="py-3 px-4 font-medium text-sm text-[var(--text-secondary)]">Employee</th>
                  <th className="py-3 px-4 font-medium text-sm text-[var(--text-secondary)]">Department</th>
                  <th className="py-3 px-4 font-medium text-sm text-[var(--text-secondary)]">Location</th>
                  <th className="py-3 px-4 font-medium text-sm text-[var(--text-secondary)]">Status</th>
                  <th className="py-3 px-4 font-medium text-sm text-[var(--text-secondary)] text-right">Current Salary</th>
                </tr>
              </thead>
              <tbody>
                {employees.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="text-center py-8 text-[var(--text-secondary)]">No employees found.</td>
                  </tr>
                ) : (
                  employees.map((emp) => (
                    <tr 
                      key={emp.id} 
                      onClick={() => handleRowClick(emp.id)}
                      className="border-b border-[var(--border-color)] hover:bg-[var(--bg-primary)] cursor-pointer transition-colors"
                    >
                      <td className="py-3 px-4">
                        <div className="font-medium">{emp.full_name}</div>
                        <div className="text-xs text-[var(--text-secondary)]">{emp.email} • {emp.employee_number}</div>
                      </td>
                      <td className="py-3 px-4">
                        <div>{emp.department}</div>
                        <div className="text-xs text-[var(--text-secondary)]">{emp.job_title}</div>
                      </td>
                      <td className="py-3 px-4">{emp.country}</td>
                      <td className="py-3 px-4">
                        <Badge variant={emp.active ? 'success' : 'default'}>
                          {emp.active ? 'Active' : 'Inactive'}
                        </Badge>
                      </td>
                      <td className="py-3 px-4 text-right font-medium">
                        {formatSalary(emp.current_gross_salary, emp.currency)}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}

        {meta && meta.total_pages > 1 && (
          <div className="pagination p-4 flex justify-between items-center border-t border-[var(--border-color)]">
            <span className="text-sm text-[var(--text-secondary)]">
              Showing {(meta.page - 1) * meta.per_page + 1} to {Math.min(meta.page * meta.per_page, meta.total)} of {meta.total} results
            </span>
            <div className="flex gap-2">
              <Button 
                variant="secondary" 
                size="sm" 
                disabled={meta.page === 1}
                onClick={() => setPage(p => Math.max(1, p - 1))}
              >
                <ChevronLeft size={16} /> Previous
              </Button>
              <Button 
                variant="secondary" 
                size="sm"
                disabled={meta.page === meta.total_pages}
                onClick={() => setPage(p => Math.min(meta.total_pages, p + 1))}
              >
                Next <ChevronRight size={16} />
              </Button>
            </div>
          </div>
        )}
      </Card>
    </div>
  );
}
