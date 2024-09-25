import { Component, OnInit, ViewChild } from '@angular/core';
import { AbstractControl, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AlertController, IonicSlides, IonModal, PickerController } from '@ionic/angular';
import { Storage } from '@ionic/storage-angular';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-confirm-services',
  templateUrl: './confirm-services.component.html',
  styleUrls: ['./confirm-services.component.scss'],
})
export class ConfirmServicesComponent {
  formCartaoCredito!: FormGroup;
  isModalOpen = false;
  mensagemValidacao = '';

  currentAtendimentos:any[] = [];
  @ViewChild('modalService', { static: false }) modalService!: IonModal;

  constructor(
    private formBuilder: FormBuilder,
    private http: HttpClient,
    private storage: Storage,
    private alertController: AlertController
  ) {


  }

  ngOnInit() {
    this.formCartaoCredito = this.formBuilder.group({
      numero: [
        '',
        [
          Validators.required,
          Validators.minLength(16),
          Validators.maxLength(16),
        ],
      ],
      nome: ['', [Validators.required]],
      validade: ['', [Validators.required, this.validarDataValidade]],
      cvv: [
        '',
        [Validators.required, Validators.minLength(3), Validators.maxLength(3)],
      ],
    });
    this.loadAtendimentos();
    console.log(this.luhnCheck("4078430016592971"));

  }

  async loadAtendimentos() {
    const atendimentos = await this.getAtendimentos();
    if (atendimentos) {
      this.currentAtendimentos = atendimentos;
      console.log(this.currentAtendimentos[0]);

      // Faça algo com os atendimentos, por exemplo, mostrá-los na tela
    } else {
      // Lógica caso não tenha atendimentos salvos
    }
  }

  async getAtendimentos() {
    try {
      const atendimentos = await this.storage.get('atendimentos');
      if (atendimentos) {
        console.log('Atendimentos recuperados:', atendimentos);
        return atendimentos;
      } else {
        console.log('Nenhum atendimento encontrado no storage.');
        return null;
      }
    } catch (error) {
      console.error('Erro ao recuperar os atendimentos:', error);
      return null;
    }
  }

  // Validação da data de validade (MM/AA)
  validarDataValidade(control: any) {
    const regex = /^(0[1-9]|1[0-2])\/?([0-9]{2})$/;
    if (!regex.test(control.value)) {
      return { invalidDate: true };
    }
    return null;
  }

  // Função para validar o cartão
  validarCartao() {
    if (this.formCartaoCredito.valid) {
      const numeroCartao = this.formCartaoCredito.get('numero')?.value;
      const url = `https://lookup.binlist.net/${numeroCartao}`;

      // Chamada para API BinList para validar o número do cartão
      this.http.get(url).subscribe(
        (data: any) => {
          this.mensagemValidacao = `Cartão válido! Banco: ${data.bank?.name || 'Não informado'}, Tipo: ${data.type}`;
          this.isModalOpen = true;
        },
        (error:any) => {
          this.mensagemValidacao = 'Número de cartão inválido. Por favor, verifique os dados.';
          this.isModalOpen = true;
        }
      );
    } else {
      this.mensagemValidacao = 'Por favor, preencha todos os campos corretamente.';
      this.isModalOpen = true;
    }
  }

  luhnCheck(cardNumber:any) {
    let sum = 0;
    let shouldDouble = false;

    // Itera sobre os dígitos do cartão de trás para frente
    for (let i = cardNumber.length - 1; i >= 0; i--) {
        let digit = parseInt(cardNumber[i]);

        if (shouldDouble) {
            // Dobra o dígito e soma os dígitos do resultado
            digit *= 2;
            if (digit > 9) digit -= 9;
        }

        sum += digit;
        shouldDouble = !shouldDouble;
    }

    return sum % 10 === 0;
  }

  submit(){

  }
  async canDismiss(data?: any, role?: string) {
    return role !== 'gesture';
  }
}
