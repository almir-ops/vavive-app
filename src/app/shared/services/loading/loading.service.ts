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
// Exibe o loading apenas se for a primeira requisição
async showLoading() {
  this.requestCount++; // Incrementa o contador de requisições
  console.log('[showLoading] Requisições ativas:', this.requestCount);

  if (this.requestCount === 1 && !this.loading) {
    this.loading = await this.loadingController.create({
      animated: true,
      backdropDismiss: false,
      showBackdrop: true,
      spinner: 'bubbles',
      message: 'Carregando...',
      cssClass: 'custom-spinner'
    });
    await this.loading.present();
    console.log('[showLoading] Loading exibido');
  }
}


// Esconde o loading apenas se todas as requisições terminarem
async hideLoading() {
  if (this.requestCount > 0) {
    this.requestCount--; // Decrementa o contador apenas se for maior que zero
    console.log('[hideLoading] Requisições ativas:', this.requestCount);
  } else {
    console.warn('[hideLoading] Tentativa de decrementar requestCount já zerado.');
  }

  if (this.requestCount === 0 && this.loading) {
    await this.loading.dismiss();
    this.loading = null; // Reseta o objeto loading após o dismiss
    console.log('[hideLoading] Loading escondido');
  }
}


}
