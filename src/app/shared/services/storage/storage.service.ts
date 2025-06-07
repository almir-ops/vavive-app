import { Injectable } from '@angular/core';
import { Preferences } from '@capacitor/preferences';
import { from, Observable } from 'rxjs';

export const APP_TOKEN = 'app_token';

@Injectable({
  providedIn: 'root'
})
export class StorageService{

  constructor() { }


  getItem(key:any){
    return localStorage.getItem(key);
  }

  getArray(key:any){
    return localStorage.getItem(JSON.parse(key));
  }

  setItem(key:any, data:any){
    return localStorage.setItem(key, data);
  }

  setArray(key:any, data:any){
    return localStorage.setItem(key,  JSON.stringify(data));
  }

  deleteItem(key:any){
    return localStorage.removeItem(key);
  }

  deleteAllStorage(){
    return localStorage.clear();
  }

  setStorage(key: string, value: any) {
    Preferences.set({key: key, value: value});
  }

  getStorage(key: string): any {
    // Preferences.migrate();
    return Preferences.get({key: key});
  }

  removeStorage(key: string) {
    Preferences.remove({key: key});
  }

  clearStorage() {
    Preferences.clear();
  }

  getToken(): Observable<any> {
    return from(this.getStorage(APP_TOKEN));
  }
}
