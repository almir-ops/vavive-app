import { Injectable } from '@angular/core';
import { LoadingController } from '@ionic/angular';

@Injectable({
  providedIn: 'root'
})
export class LoadingService {
  public loading: HTMLIonLoadingElement | null = null;
  public requestCount = 0; // Contador de requisições ativas

  constructor(private loadingController: LoadingController) {}

  // Exibe o loading apenas se for a primeira requisição
  async showLoading() {
    if (this.requestCount === 0 && !this.loading) {
      this.loading = await this.loadingController.create({
        animated: true,
        backdropDismiss: false,
        showBackdrop: true,
        spinner: 'bubbles',
        message: 'Carregando...',
        cssClass: 'custom-spinner'
      });
      await this.loading.present();
      //console.log('[showLoading] Loading exibido');
    }
    this.requestCount++; // Incrementa o contador de requisições
  }

  // Esconde o loading apenas se todas as requisições terminarem
  async hideLoading() {
    this.requestCount--; // Decrementa o contador de requisições
    console.log('[hideLoading] requestCount:', this.requestCount);
    console.log('[hideLoading] loading:', this.loading);


    if (this.requestCount === 0 && this.loading) {
      await this.loading.dismiss();
      this.loading = null; // Reseta o objeto loading após o dismiss
      //console.log('[hideLoading] Loading escondido');
    }
  }
}
