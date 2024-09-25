import { Component, OnInit, ViewChild } from '@angular/core';
import { AbstractControl, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AlertController, IonicSlides, IonModal, PickerController } from '@ionic/angular';
import * as moment from 'moment';
import { Preferences } from '@capacitor/preferences';
import { Storage } from '@ionic/storage-angular';
import { ServicosService } from 'src/app/shared/services/servicos/servicos.service';
import { uPlano } from 'src/app/shared/interfaces/uPlano';
import { ViacepService } from 'src/app/shared/services/viacep/viacep.service';

@Component({
  selector: 'app-services',
  templateUrl: './services.component.html',
  styleUrls: ['./services.component.scss'],
})
export class ServicesComponent{


}
