// src/types/inventory.ts

// src/types/inventory.ts
export interface InventoryItem {
  id: string;
  name: string;
  category: 'bulb' | 'battery';
  type: string;
  shape?: string;
  location?: string;
  requiredCount: number;
  notes?: string;
  colorTemp?: string;
  wattage?: number;
  lumens?: number;
  dimmable?: boolean;
  rechargeable?: boolean;
  lastReplaced?: string; // Datoen kjem som streng frå API-et
}

export interface StockItem {
  id: string;
  type: string;
  shape?: string; // Lagt til for å skille f.eks. E27 Standard fra E27 Krone
  category: 'battery' | 'bulb';
  currentCount: number;
  minThreshold: number;
}