// loading.service.ts
import { Injectable } from '@angular/core';
import { LoadingController } from '@ionic/angular';

@Injectable({
  providedIn: 'root'
})
export class LoadingService {
  private loading!: HTMLIonLoadingElement;
  private requestCount = 0;

  constructor(private loadingController: LoadingController) {}

  async showLoading(): Promise<void> {
    this.requestCount++;

    if (this.requestCount === 1) { // Exibe o loading apenas na primeira requisição
      this.loading = await this.loadingController.create({
        animated: true,
        backdropDismiss: false,
        showBackdrop: true,
        spinner: 'bubbles',
        message: 'Carregando...',
        cssClass: 'custom-spinner'
      });
      await this.loading.present();
    }
  }

  async hideLoading(): Promise<void> {
    if (this.requestCount > 0) {
      this.requestCount--;
    }

    if (this.requestCount === 0 && this.loading) { // Esconde o loading apenas quando todas as requisições terminam
      await this.loading.dismiss();
      this.loading = null as any;
    }
  }
}
