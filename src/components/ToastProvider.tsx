import { Toaster } from 'react-hot-toast';

export default function ToastProvider() {
  return (
    <Toaster
      position="top-center"
      reverseOrder={false}
      gutter={8}
      toastOptions={{
        // Default options
        duration: 3000,
        style: {
          background: '#fff',
          color: '#0f172a',
          padding: '16px',
          borderRadius: '16px',
          boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
          border: '1px solid #e2e8f0',
          fontWeight: '600',
        },
        // Success
        success: {
          duration: 3000,
          style: {
            background: '#f0fdf4',
            color: '#166534',
            border: '1px solid #86efac',
          },
          iconTheme: {
            primary: '#22c55e',
            secondary: '#f0fdf4',
          },
        },
        // Error
        error: {
          duration: 4000,
          style: {
            background: '#fef2f2',
            color: '#991b1b',
            border: '1px solid #fca5a5',
          },
          iconTheme: {
            primary: '#ef4444',
            secondary: '#fef2f2',
          },
        },
        // Loading
        loading: {
          style: {
            background: '#fffbeb',
            color: '#92400e',
            border: '1px solid #fde68a',
          },
          iconTheme: {
            primary: '#f59e0b',
            secondary: '#fffbeb',
          },
        },
      }}
    />
  );
}
