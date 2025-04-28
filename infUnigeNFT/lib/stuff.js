import { toast } from 'vue-sonner'

export function showError (title, e) {
    if (e && e.reason){
      toast.error(title, { description: e.reason , duration: 5000 });
      console.error(e);
    } else toast.error(title, { duration: 5000 });
  }