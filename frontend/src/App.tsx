import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Layout } from './components/Layout';
import { Dashboard } from './pages/Dashboard';
import { EmployeeDirectory } from './pages/EmployeeDirectory';
import { EmployeeDetail } from './pages/EmployeeDetail';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="employees" element={<EmployeeDirectory />} />
          <Route path="employees/:id" element={<EmployeeDetail />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
