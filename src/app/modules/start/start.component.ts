import { CommonModule } from '@angular/common';
import {
  CUSTOM_ELEMENTS_SCHEMA,
  Component,
  ElementRef,
  Input,
  OnInit,
  ViewChild,
} from '@angular/core';
import { IonicSlides } from '@ionic/angular';
import { register } from 'swiper/element/bundle';
import { AuthService } from '../auth/auth.service';
import { Storage } from '@ionic/storage-angular';
import Swiper from 'swiper';
import { Router } from '@angular/router';
import { Preferences } from '@capacitor/preferences';
import { ServicosService } from 'src/app/shared/services/servicos/servicos.service';
import { LoadingComponent } from 'src/app/shared/components/loading/loading.component';
import { ClientesService } from 'src/app/shared/services/clientes/clientes.service';
register();

@Component({
  selector: 'app-start',
  templateUrl: './start.component.html',
  styleUrls: ['./start.component.scss'],
})
export class StartComponent implements OnInit {
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

  user: any;
  @ViewChild('loadingComponent') loadingComponent!: LoadingComponent;
  loaded = true;
  images = [
    './assets/images/VA.png',
    './assets/images/VI.png',
    './assets/images/Ve.png',
  ];
  customStyles = [
    'h-24 -top-4 -left-6', // Estilo para VA.png
    'h-24 -top-4 -left-4', // Estilo para VA.png
    'h-24 -top-4 -left-6', // Estilo para VI.png
  ];
  currentImageIndex = 0;
  frontUrl = '';
  constructor(
    private authService: AuthService,
    private storage: Storage,
    private router: Router,
    private servicosServices: ServicosService,
    private clienteService: ClientesService
  ) {}

  ngOnInit() {
    this.getFrontUrl().then((url) => {
      if (url) {
        // Use a URL como necessário
        this.frontUrl = url;
        this.slidesUtils = [
          {
            ID: 1,
            name: 'Cadastre-se como parceiro',
            slogan: 'Faça parte de nossa equipe',
            bannerApp: './assets/images/quero-trabalhar.jpeg',
            link: `https://${this.frontUrl}/pre-cadastro-profissional`,
          },

          {
            ID: 2,
            name: 'Seja um franqueado',
            slogan: 'Não perca tempo e comece a faturar muito!',
            bannerApp: './assets/images/seja-franqueado.jpeg',
            link: 'https://www.vavive.com.br/seja-um-franqueado-oficial',
          },
        ];
      } else {
      }
    });

    this.slidesUtils2 = [
      {
        name: 'GARANTIA',
        slogan:
          'Profissionais qualificados, sempre no dia e horário combinados.',
        bannerApp: './assets/images/banner-padrao.png',
      },
      {
        name: 'FLEXIBILIDADE',
        slogan:
          'Com a VAVIVÊ, você agenda, reagenda e relaxa. Nós cuidamos do resto!',
        bannerApp: './assets/images/banner-padrao.png',
      },
      {
        name: 'CONFIANÇA',
        slogan:
          'Sua confiança garantida em cada serviço, sempre no dia e horário combinados.',
        bannerApp: './assets/images/banner-padrao.png',
      },
    ];
    this.startImageLoop();
  }

  async getFrontUrl(): Promise<string | null> {
    const url = await this.storage.get('front_url');
    return url ? url : null;
  }

  ionViewWillEnter() {
    this.initializeUserData();
    const storedSlides = localStorage.getItem('slides');

    if (storedSlides) {
      // Se o array já estiver salvo no localStorage, usa o valor armazenado
      this.slides = JSON.parse(storedSlides);
      console.log('Loaded slides from localStorage:', this.slides);
    } else {
      // Faz a chamada ao serviço se não houver slides no localStorage
      this.servicosServices.getServicos().subscribe({
        next: (value: any) => {
          console.log('API response:', value.items);

          // Filtra e ordena os itens
          const filteredItems = value.items.filter(
            (item: any) =>
              item.nome !== 'Limpeza pesada' &&
              item.nome !== 'Recrutamento e seleção'
          );

          console.log(filteredItems);

          const sortedItems = filteredItems.sort((a: any, b: any) => {
            if (a.nome === 'Limpeza residencial') return -1;
            if (b.nome === 'Limpeza residencial') return 1;
            if (a.nome === 'Limpeza empresarial') return -1;
            if (b.nome === 'Limpeza empresarial') return 1;
            return 0;
          });

          // Armazena os itens processados no localStorage
          localStorage.setItem('slides', JSON.stringify(sortedItems));
          this.slides = sortedItems;
          console.log('Slides saved to localStorage:', this.slides);
        },
        error: (err: any) => {
          console.error('Error fetching servicos:', err);
        },
      });
    }
  }

  async initializeUserData() {
    await this.loadUserFromStorage();
  }

  async loadUserFromStorage() {
    try {
      const userData = await Preferences.get({ key: 'user_data' });
      if (userData.value) {
        // Usuário já está salvo localmente
        this.user = JSON.parse(userData.value).cliente;
        this.userLoggedOut = false;
      } else {
        // Nenhum usuário salvo, chamando API para obter informações do usuário
        await this.getInfoUser();
      }
    } catch (error) {
      console.error('Error loading user from storage:', error);
    }
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
            const token_notification = await Preferences.get({
              key: 'token_notification',
            });
            this.userLoggedOut = false;
            this.user = response.cliente;
            this.user.token_notification = token_notification.value;
            this.clienteService
              .updateClient(this.user, this.user.source_api)
              .subscribe({
                next: (value: any) => {
                  console.log('User atualizado: ', value);
                },
                error: (err: any) => {
                  console.log(err);
                },
              });
            // Armazenar o usuário de forma segura para chamadas futuras
            await this.saveUserSecurely(response);
          },
          error: (err: any) => {
            console.log(err);
            this.userLoggedOut = true;
          },
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

  navegate(rota: string) {
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

  navegateByparam(rota: string, IDservice: string, index: any) {
    console.log(IDservice);

    this.router.navigate([rota], {
      queryParams: { tipo: IDservice, i: index },
    });
  }

  navegateExternalLink(link: string) {
    window.open(link, '_blank');
  }

  startImageLoop() {
    setInterval(() => {
      this.currentImageIndex =
        (this.currentImageIndex + 1) % this.images.length;
    }, 5000); // Troca a cada 3 segundos
  }
}
