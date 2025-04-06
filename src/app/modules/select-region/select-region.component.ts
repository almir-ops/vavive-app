import { Component, ViewChild } from '@angular/core';
import { Router } from '@angular/router';
import { IonModal } from '@ionic/angular';
import { Storage } from '@ionic/storage-angular';
import { MaskitoElementPredicate, MaskitoOptions } from '@maskito/core';
import { FranquiasService } from 'src/app/shared/services/franquias/franquias.service';
import { ViacepService } from 'src/app/shared/services/viacep/viacep.service';

@Component({
  selector: 'app-select-region',
  templateUrl: './select-region.component.html',
  styleUrls: ['./select-region.component.scss'],
})
export class SelectRegionComponent {

  regions: any[] = [];

  cepMask: MaskitoOptions = {
    mask: [
      /\d/, /\d/, /\d/, /\d/, /\d/, '-', /\d/, /\d/, /\d/
    ]
  };

  @ViewChild('modalSejaFranqueado', { static: false }) modalSejaFranqueado!: IonModal;
  @ViewChild('modalFranquias', { static: false }) modalFranquias!: IonModal;


  public readonly predicate: MaskitoElementPredicate = (element) =>
    (element as HTMLIonInputElement).getInputElement();

  franquiaNotFound = false;
  hideModal = false;

  regionsCurrent: any[] = [];

  constructor(
    private storage: Storage,
    private router: Router,
    private viacepService: ViacepService,
    private franquiasService: FranquiasService
  ) {}

  ngOnInit(): void {
    this.franquiasService.getFranquias().subscribe(data => {
      this.regions = data;
      console.log(this.regions);
    });
    localStorage.removeItem('slides');
  }

  ionViewWillEnter() {
    const hideModal = localStorage.getItem('hideModalFranqueado')
    console.log(hideModal);

    if(hideModal !== 'true'){
      this.modalSejaFranqueado.present();
    }

  }
  async searchCep(event: any) {
    let cep = event.target.value;

    // Remove tudo que não for dígito
    cep = cep.replace(/\D/g, '');
    console.log(cep);
    this.franquiaNotFound = false;

    if (cep.length === 8) {
    // Chama o serviço ViaCEP para obter os dados do endereço
    this.viacepService.buscarEndereco(cep).subscribe(
      async (endereco: any) => {
        if (endereco && !endereco.erro) {
          console.log('Endereço encontrado:', endereco);
          console.log(this.regions);

          let region: any;

          // Primeiro, busca pela cidade na lista de franquias
          region = this.regions.find((r: any) =>
            r.cidade.toLowerCase() === endereco.localidade.toLowerCase()
          );

          if (region) {
            console.log('Cidade encontrada na franquia:', region);
          } else {
            console.log('Cidade não encontrada. Comparando com:', endereco.localidade);
          }

          // Se não encontrou a cidade e o estado é DF, buscar pela franquia correspondente ao estado
          if (!region && endereco.uf === 'DF') {
            region = this.regions.find((r: any) => r.estado.toLowerCase() === 'df');
            if (region) {
              console.log('Estado DF encontrado na franquia:', region);
            } else {
              console.log('Estado DF não encontrado. Comparando com:', endereco.uf);
            }
          }

            // Verificar se o CEP está dentro da faixa de valores
            if (!region) {
              const cepNumber = parseInt(cep.replace('-', ''), 10); // Remove o hífen e converte para número
              console.log('Verificando faixa de CEP:', cepNumber);

              region = this.regions.find((r: any) => {
                const startCep = parseInt(r.latitude.replace('-', ''), 10); // Remove o hífen e converte
                const endCep = parseInt(r.longitude.replace('-', ''), 10);  // Remove o hífen e converte

                console.log(`Comparando CEP ${cepNumber} com faixa: ${startCep} - ${endCep}`);
                return cepNumber >= startCep && cepNumber <= endCep;
              });

              if (region) {
                console.log('CEP encontrado na faixa da franquia:', region);
              } else {
                console.log('CEP não encontrado na faixa. Comparando:', cepNumber);
              }
            }


          // Se ainda não encontrou, verificar se o CEP está dentro da faixa de valores
          if (!region) {
            const cepNumber = parseInt(cep, 10); // Certifique-se de que o CEP é tratado como número
            console.log('Verificando faixa de CEP:', cepNumber);

            region = this.regions.find((r: any) =>
              cepNumber >= parseInt(r.latitude, 10) && cepNumber <= parseInt(r.longitude, 10)
            );

            if (region) {
              console.log('CEP encontrado na faixa da franquia:', region);
            } else {
              console.log('CEP não encontrado na faixa. Comparando:', cepNumber);
            }
          }

          const cidadeComFranquiaEncontrada = this.regions.some((r: any) =>
            r.embed_cidade.toLowerCase() === endereco.localidade.toLowerCase()
          );

          // Se não encontrou uma franquia mas a cidade tem franquia, mostra o modal
          if (!region && cidadeComFranquiaEncontrada) {
            console.log(this.regions);
            this.modalFranquias.present();

            // Filtra apenas as franquias da mesma cidade
            const franquiasDaCidade = this.regions.filter((r: any) =>
              r.embed_cidade.toLowerCase() === endereco.localidade.toLowerCase()
            );

            // Remove duplicadas (se tiver com mesmo nome)
            this.regionsCurrent = franquiasDaCidade.reduce((unique: any[], region: any) => {
              if (!unique.some((item) => item.nome === region.nome)) {
                unique.push(region);
              }
              return unique;
            }, []);
          }

          if (region) {
            await this.storage.set('endereco', endereco);
            await this.storage.set('front_url', region.url_front);
            await this.storage.set('api_url', region.url);
            await this.storage.set('franquia', region.nome);
            await this.storage.set('email_franquia', region.email_contato);
            await this.storage.set('contato_franquia', region.numero_contato);

            await this.storage.set('current_cep', cep);

            const apiUrl = await this.storage.get('api_url');
            this.router.navigate(['/start']);
          } else {
            console.log('Localidade não encontrada em nenhuma franquia.');
            this.franquiaNotFound = true;
          }

        } else {
          this.franquiaNotFound = true;
          console.log('CEP inválido ou não encontrado.');
        }
      },
      (error: any) => {
        console.error('Erro ao buscar o CEP:', error);
      }
    );



    } else {
      console.log('CEP incompleto ou inválido.');
    }
  }

  openExternalLink(url: string): void {
    window.open(url, '_blank');
  }

  changeHideModal(){
    if(this.hideModal){
      localStorage.setItem('hideModalFranqueado', 'true');
    }
  }

  selectFranquia(region: any){

    this.storage.set('endereco', region);
    this.storage.set('front_url', region.url_front);
    this.storage.set('api_url', region.url);
    this.storage.set('franquia', region.nome);
    this.storage.set('email_franquia', region.email_contato);
    this.storage.set('contato_franquia', region.numero_contato);

    this.modalFranquias.dismiss();

    this.router.navigate(['/start']);
  }

}
