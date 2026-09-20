import React, { useEffect, useState, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { api, ApiError } from '../lib/api';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { Spinner } from '../components/ui/Spinner';
import { Modal } from '../components/ui/Modal';
import { ArrowLeft, Plus, MapPin, Briefcase, Calendar } from 'lucide-react';
import './EmployeeDetail.css';

interface SalaryHistory {
  id: number;
  gross_salary: number;
  effective_date: string;
  reason: string;
  notes: string;
}

interface EmployeeDetailData {
  id: number;
  employee_number: string;
  full_name: string;
  email: string;
  department: string;
  country: string;
  job_title: string;
  level: string;
  currency: string;
  hired_on: string;
  active: boolean;
  salary_histories: SalaryHistory[];
}

export function EmployeeDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [employee, setEmployee] = useState<EmployeeDetailData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  
  // Modal state
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [newSalary, setNewSalary] = useState('');
  const [effectiveDate, setEffectiveDate] = useState(new Date().toISOString().split('T')[0]);
  const [reason, setReason] = useState('merit_increase');
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [formError, setFormError] = useState('');

  const loadEmployee = useCallback(async () => {
    try {
      const response = await api.get<{ employee: EmployeeDetailData }>(`/api/employees/${id}`);
      setEmployee(response.employee);
    } catch (err) {
      if (err instanceof ApiError && err.status === 404) {
        setError('Employee not found.');
      } else {
        setError('Failed to load employee details.');
      }
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    loadEmployee();
  }, [loadEmployee]);

  const handleAddSalary = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setFormError('');

    try {
      await api.post(`/api/employees/${id}/salaries`, {
        salary: {
          gross_salary: parseFloat(newSalary),
          effective_date: effectiveDate,
          reason,
          notes
        }
      });
      
      setIsModalOpen(false);
      setNewSalary('');
      setNotes('');
      // Reload employee to get new salary history
      loadEmployee();
    } catch (err) {
      if (err instanceof ApiError && err.body && typeof err.body === 'object' && 'errors' in err.body) {
        const errors = (err.body as any).errors;
        const msg = Object.entries(errors).map(([k, v]) => `${k} ${v}`).join(', ');
        setFormError(msg);
      } else {
        setFormError('Failed to add salary record.');
      }
    } finally {
      setSubmitting(false);
    }
  };

  const formatSalary = (amount: number, currency: string) => {
    return new Intl.NumberFormat('en-US', { style: 'currency', currency }).format(amount);
  };

  if (loading) {
    return <div className="flex justify-center p-12"><Spinner /></div>;
  }

  if (error || !employee) {
    return (
      <div className="text-center p-12">
        <h2 className="text-xl mb-4 text-[var(--danger)]">{error}</h2>
        <Button onClick={() => navigate('/employees')}>Back to Directory</Button>
      </div>
    );
  }

  return (
    <div className="detail-page">
      <Button variant="ghost" className="mb-6" onClick={() => navigate('/employees')}>
        <ArrowLeft size={16} /> Back to Directory
      </Button>

      <div className="grid grid-cols-3 gap-6">
        <div className="col-span-1">
          <Card>
            <CardContent className="flex-col items-center text-center p-8">
              <div className="avatar-large mb-4">
                {employee.full_name.split(' ').map(n => n[0]).join('')}
              </div>
              <h2 className="text-xl mb-1">{employee.full_name}</h2>
              <p className="text-secondary mb-4">{employee.job_title} • {employee.department}</p>
              
              <Badge variant={employee.active ? 'success' : 'default'} className="mb-6">
                {employee.active ? 'Active' : 'Inactive'}
              </Badge>

              <div className="info-list text-left w-full mt-4 flex flex-col gap-3">
                <div className="flex items-center gap-3 text-sm text-secondary">
                  <MapPin size={16} /> <span>{employee.country}</span>
                </div>
                <div className="flex items-center gap-3 text-sm text-secondary">
                  <Briefcase size={16} /> <span>{employee.level} Level</span>
                </div>
                <div className="flex items-center gap-3 text-sm text-secondary">
                  <Calendar size={16} /> <span>Hired {new Date(employee.hired_on).toLocaleDateString()}</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="col-span-2 flex flex-col gap-6">
          <Card>
            <CardHeader className="flex justify-between items-center" style={{ flexDirection: 'row' }}>
              <CardTitle>Salary History</CardTitle>
              {employee.active && (
                <Button onClick={() => setIsModalOpen(true)} size="sm">
                  <Plus size={16} /> Add Salary Record
                </Button>
              )}
            </CardHeader>
            <CardContent>
              {employee.salary_histories.length === 0 ? (
                <p className="text-secondary text-center py-8">No salary history recorded.</p>
              ) : (
                <div className="timeline">
                  {employee.salary_histories.map((history) => (
                    <div key={history.id} className="timeline-item">
                      <div className="timeline-dot"></div>
                      <div className="timeline-content border p-4 rounded-md mb-4 bg-[var(--bg-primary)]">
                        <div className="flex justify-between mb-2">
                          <h3 className="font-semibold text-lg text-[var(--brand-primary)]">
                            {formatSalary(history.gross_salary, employee.currency)}
                          </h3>
                          <span className="text-sm text-secondary">
                            {new Date(history.effective_date).toLocaleDateString()}
                          </span>
                        </div>
                        <div className="flex justify-between items-end">
                          <div>
                            <Badge variant="default" className="mb-2 uppercase text-xs">{history.reason.replace('_', ' ')}</Badge>
                            {history.notes && <p className="text-sm text-secondary mt-1">{history.notes}</p>}
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>

      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} title="Add Salary Record">
        <form onSubmit={handleAddSalary} className="flex flex-col gap-4">
          {formError && <div className="text-[var(--danger)] bg-[var(--danger-bg)] p-3 rounded-md text-sm">{formError}</div>}
          
          <div className="form-group">
            <label className="block text-sm font-medium mb-1">New Gross Salary ({employee.currency})</label>
            <input 
              type="number" 
              required
              min="1"
              step="0.01"
              className="w-full border p-2 rounded-md bg-[var(--bg-primary)]"
              value={newSalary}
              onChange={e => setNewSalary(e.target.value)}
            />
          </div>

          <div className="form-group">
            <label className="block text-sm font-medium mb-1">Effective Date</label>
            <input 
              type="date" 
              required
              className="w-full border p-2 rounded-md bg-[var(--bg-primary)]"
              value={effectiveDate}
              onChange={e => setEffectiveDate(e.target.value)}
            />
          </div>

          <div className="form-group">
            <label className="block text-sm font-medium mb-1">Reason</label>
            <select 
              className="w-full border p-2 rounded-md bg-[var(--bg-primary)]"
              value={reason}
              onChange={e => setReason(e.target.value)}
            >
              <option value="hire">Hire</option>
              <option value="promotion">Promotion</option>
              <option value="merit_increase">Merit Increase</option>
              <option value="cost_of_living">Cost of Living</option>
              <option value="correction">Correction</option>
            </select>
          </div>

          <div className="form-group">
            <label className="block text-sm font-medium mb-1">Notes (Optional)</label>
            <textarea 
              className="w-full border p-2 rounded-md bg-[var(--bg-primary)]"
              rows={3}
              value={notes}
              onChange={e => setNotes(e.target.value)}
            ></textarea>
          </div>

          <div className="flex justify-end gap-2 mt-4">
            <Button type="button" variant="ghost" onClick={() => setIsModalOpen(false)}>Cancel</Button>
            <Button type="submit" isLoading={submitting}>Save Record</Button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
