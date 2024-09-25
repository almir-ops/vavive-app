import { Component, OnInit } from '@angular/core';
import { Storage } from '@ionic/storage-angular';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss'],
})
export class HomeComponent  implements OnInit {

  constructor(
    private storage: Storage,
  ) {
    const apiUrl = this.storage.get('api_url');
    console.log(apiUrl);

  }

  ngOnInit() {}

}
