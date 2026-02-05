// Client-side utility functions for showing toast notifications
import toast from 'react-hot-toast';

// Success toast
export function showSuccess(message: string) {
  toast.success(message);
}

// Error toast
export function showError(message: string) {
  toast.error(message);
}

// Loading toast
export function showLoading(message: string) {
  return toast.loading(message);
}

// Promise toast (automatically shows loading, then success or error)
export function showPromise<T>(
  promise: Promise<T>,
  messages: {
    loading: string;
    success: string;
    error: string;
  }
) {
  return toast.promise(promise, messages);
}

// Custom toast
export function showToast(message: string, options = {}) {
  toast(message, options);
}

// Dismiss a specific toast or all toasts
export function dismissToast(toastId?: string) {
  if (toastId) {
    toast.dismiss(toastId);
  } else {
    toast.dismiss();
  }
}
