import { CommonModule } from '@angular/common';
import { CUSTOM_ELEMENTS_SCHEMA, Component, ElementRef, Input, OnInit, ViewChild } from '@angular/core';
import { IonicSlides } from '@ionic/angular';
import { register } from 'swiper/element/bundle';
import { AuthService } from '../auth/auth.service';
import { Storage } from '@ionic/storage-angular';
import Swiper from 'swiper';
import { Router } from '@angular/router';
import { Preferences } from '@capacitor/preferences';

register();

@Component({
  selector: 'app-start',
  templateUrl: './start.component.html',
  styleUrls: ['./start.component.scss']
})
export class StartComponent  implements OnInit {

  @Input() slides: any[] = [];
  @Input() slidesUtils: any[] = [];
  @Input() slidesUtils2: any[] = [];
  swiperModules = [IonicSlides];
  @ViewChild('swiper', { static: false }) swiperContainer: any;
  swiper!: Swiper;

  userLoggedOut!: boolean;
  indexNumber = 2;
  appendNumber = 4;
  prependNumber = 1;

  user: any

  constructor(
    private authService: AuthService,
    private storage: Storage,
    private router:Router
  ) { }

  ngOnInit() {

    this.slides =  [
      {
        "ID": 1,
        "name": "Limpeza residencial",
        "slogan": "Deixe sua casa brilhando.",
        "bannerApp": "./assets/images/residencial.png"
      },
      {
        "ID": 2,
        "name": "Limpeza empresarial",
        "slogan": "Seu escritório sempre impecável.",
        "bannerApp": "./assets/images/empresarial.png"
      },
      {
        "ID": 3,
        "name": "Limpeza pós obra",
        "slogan": "Tire a poeira da reforma.",
        "bannerApp": "./assets/images/pos-obra.png"
      },
      {
        "ID": 4,
        "name": "Passar roupas",
        "slogan": "Roupas passadas com carinho.",
        "bannerApp": "./assets/images/passar-roupa.png"
      },
      {
        "ID": 5,
        "name": "Cozinhar",
        "slogan": "Delícias preparadas especialmente para você.",
        "bannerApp": "./assets/images/COZINHAR.png"
      },
      {
        "ID": 6,
        "name": "Babá",
        "slogan": "Cuidado e carinho para os pequenos.",
        "bannerApp": "./assets/images/BABA.png"
      },
      {
        "ID": 7,
        "name": "Limpeza pesada",
        "slogan": "Para sujeiras difíceis, soluções eficazes.",
        "bannerApp": "./assets/images/banner-padrao.png"
      },
      {
        "ID": 8,
        "name": "Limpeza de evento",
        "slogan": "Seu evento limpo e organizado.",
        "bannerApp": "./assets/images/banner-padrao.png"
      }
    ];
    this.slidesUtils = [
      /*
      {
        name: "Indique e Ganhe",
        slogan: "Deixe sua casa brilhando.",
        bannerApp: "./assets/images/banner-padrao.png"
      },
      {
        name: "Falar com profissional",
        slogan: "Deixe sua casa brilhando.",
        bannerApp: "./assets/images/banner-padrao.png"
      },
      {
        name: "Compre produtos",
        slogan: "Deixe sua casa brilhando.",
        bannerApp: "./assets/images/banner-padrao.png"
      },
      {
        name: "Indique e Ganhe",
        slogan: "Deixe sua casa brilhando.",
        bannerApp: "./assets/images/banner-padrao.png"
      },*/

        {
          "ID": 1,
          "name": "Trabalhe conosco",
          "slogan": "Faça parte de nossa equipe de funcionarios",
          "bannerApp": "./assets/images/RH.png"
        },
        {
          "ID": 2,
          "name": "Avaliações de Clientes",
          "slogan": "Veja o que nossos clientes dizem sobre nossos serviços.",
          "bannerApp": "./assets/images/RH.png"
        }



    ]
    this.slidesUtils2= [
      {
        name: "GARANTIA",
        slogan: "Profissionais qualificados, sempre no dia e horário combinados.",
        bannerApp: "./assets/images/banner-padrao.png"
      },
      {
        name: "FLEXIBILIDADE",
        slogan: "Com a VAVIVÊ, você agenda, reagenda e relaxa. Nós cuidamos do resto!",
        bannerApp: "./assets/images/banner-padrao.png"
      },
      {
        name: "CONFIANÇA",
        slogan: "Sua Confiança Garantida em Cada Serviço, Sempre no Dia e Horário Combinados.",
        bannerApp: "./assets/images/banner-padrao.png"
      }
    ]
    this.getInfoUser();
  }

  ionViewWillEnter() {
    console.log('ionViewWillEnter');
    this.getInfoUser();
  }

  ngAfterViewInit() {
    // Acesso direto ao Swiper após a inicialização
    if (this.swiperContainer) {
      const swiper = (this.swiperContainer as any).swiper;
      if (swiper) {
        swiper.on('init', () => {
          console.log('Swiper initialized');
        });
      }
    }
  }

  async getInfoUser() {
    try {
      const paramUser = await this.storage.get('param_user');
      console.log(paramUser);

      if (paramUser) {
        this.authService.getInfoUser(paramUser).subscribe({
          next: async (response) => {
            console.log(response);
            this.userLoggedOut = false;
            this.user = response;

            // Armazenar o usuário de forma segura
            await this.saveUserSecurely(response);
          },
          error: (err: any) => {
            console.log(err);
            this.userLoggedOut = true;

          }
        });
      } else {
        console.log('param_user is null or undefined, skipping API call.');
        this.userLoggedOut = true;
      }
    } catch (error) {
      console.error('Error retrieving param_user:', error);
    }
  }


  nextSlide() {
    console.log(this.swiperContainer);

    if (this.swiperContainer && this.swiperContainer.swiper) {
      this.swiperContainer.swiper.slideNext();
    }
  }

  navegate(rota:string){
    this.router.navigate([rota]);
  }

  getFirstWord(input: string): string {
    if (!input) {
      return ''; // Retorna uma string vazia se a entrada for vazia ou indefinida
    }
    const words = input.trim().split(' '); // Remove espaços extras e divide a string por espaço
    return words[0]; // Retorna a primeira palavra
  }

  // Método para salvar o usuário de forma segura usando Capacitor Preferences
  async saveUserSecurely(user: any) {
    try {
      await Preferences.set({
        key: 'user_data',
        value: JSON.stringify(user), // Converte o objeto para string e armazena
      });
      console.log('User saved securely.');
    } catch (error) {
      console.error('Error saving user data securely:', error);
    }
  }

  // Método para recuperar o usuário do armazenamento seguro
  async getUserSecurely() {
    try {
      const { value: user } = await Preferences.get({ key: 'user_data' });
      return user ? JSON.parse(user) : null; // Converte de volta para objeto, se existir
    } catch (error) {
      console.error('Error retrieving user data securely:', error);
      return null;
    }
  }

  navegateByparam(rota: string, tipo: string,index:any) {
    this.router.navigate([rota], { queryParams: { tipo: tipo, i: index  } });
  }
}
