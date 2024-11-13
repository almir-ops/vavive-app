// alert.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class AlertService {
  private showAlertSubject = new BehaviorSubject<boolean>(false);
  showAlert$ = this.showAlertSubject.asObservable();

  openAlert() {
    this.showAlertSubject.next(true);
  }

  closeAlert() {
    this.showAlertSubject.next(false);
  }
}
