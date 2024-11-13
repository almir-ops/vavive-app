// alert.component.ts
import { Component, Input, OnInit } from '@angular/core';
import { AlertService } from '../../services/alert/alert.service';

@Component({
  selector: 'app-alert',
  templateUrl: './alert.component.html',
  styleUrls: ['./alert.component.scss'],
})
export class AlertComponent implements OnInit {
  @Input() alertButtons = ['Fechar'];
  @Input() header = 'Alerta';
  @Input() message = '';

  showAlert = false;

  constructor(private alertService: AlertService) {}

  ngOnInit() {
    this.alertService.showAlert$.subscribe((show) => {
      this.showAlert = show;
    });
  }

  closeAlert() {
    this.alertService.closeAlert();
  }
}
