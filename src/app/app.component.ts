import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { Platform } from '@ionic/angular';
import { register } from 'swiper/element/bundle';
import { Storage } from '@ionic/storage-angular';
import { StatusBar, Style } from '@capacitor/status-bar';

register();

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss'],
})
export class AppComponent {
  constructor(
    private platform: Platform,
    private storage: Storage,
    private router: Router
  ) {
    this.initializeApp();
    this.disableDarkMode()
  }

  disableDarkMode() {
    document.body.classList.add('light'); // Força o tema claro
    document.body.classList.remove('dark'); // Remove qualquer classe que ative o modo escuro
  }

  async initializeApp() {
    await this.platform.ready();
    await this.storage.create();
    const apiUrl = await this.storage.get('api_url');
    const frontUrl = await this.storage.get('front_url');
    const endereco = await this.storage.get('endereco');
    console.log(apiUrl);

    if (!apiUrl || !endereco) {
      this.router.navigate(['/select-region']);
    } else {
      this.router.navigate(['/']);
    }
  }

  configureStatusBar() {
    StatusBar.setBackgroundColor({ color: '#ffffff' });
    StatusBar.setStyle({ style: Style.Dark });
  }
}
