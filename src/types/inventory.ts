// src/types/inventory.ts
export interface InventoryItem {
  id: string;
  name: string;
  category: 'bulb' | 'battery';
  type: string;
  shape?: string;
  location?: string; // Deprecated - bruk building/department/detail
  building?: string;
  department?: string;
  detail?: string;
  requiredCount: number;
  quantity: number; // Antall identiske enheter
  notes?: string;
  colorTemp?: string;
  wattage?: number;
  lumens?: number;
  dimmable?: boolean;
  rechargeable?: boolean;
  lastReplaced?: string; // Datoen kommer som streng fra API-et
}

export interface StockItem {
  id: string;
  type: string;
  shape?: string; // Lagt til for å skille f.eks. E27 Standard fra E27 Krone
  category: 'battery' | 'bulb';
  currentCount: number;
  minThreshold: number;
  dimmable?: boolean;
  rechargeable?: boolean;
}