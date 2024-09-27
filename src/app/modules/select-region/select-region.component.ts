import { Component } from '@angular/core';
import { Router } from '@angular/router';
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
  public readonly predicate: MaskitoElementPredicate = (element) =>
    (element as HTMLIonInputElement).getInputElement();

  franquiaNotFound = false;
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

            // Comparar a localidade do endereço com os bairros da lista de franquias
            let region = this.regions.find((r: any) =>
              r.bairros.some((bairroObj: any) =>
                // Verifica se o item é um objeto com a propriedade 'nome' ou uma string e compara com endereco.localidade
                (typeof bairroObj === 'string' ? bairroObj.toLowerCase() : bairroObj.nome.toLowerCase()) === endereco.localidade.toLowerCase()
              )
            );

            // Se não encontrou uma franquia e o estado é SP ou RJ, usa a franquia "Matriz"
            if (!region && (endereco.uf === 'SP' || endereco.uf === 'RJ')) {
              region = this.regions.find((r: any) => r.nome.toLowerCase() === 'matriz');
            }

            if (region) {
              console.log('Franquia encontrada para a localidade:', region.nome);
              await this.storage.set('endereco', endereco);
              await this.storage.set('front_url', region.url_front);
              await this.storage.set('api_url', region.url);
              await this.storage.set('franquia', region.nome);
              await this.storage.set('current_cep', cep);

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

}
