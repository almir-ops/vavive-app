package io.ionic.starter;

import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Configurações para desativar ajuste de texto
    WebView webView = findViewById(R.id.webview);
    if (webView != null) {
      WebSettings settings = webView.getSettings();
      settings.setTextZoom(100); // Força zoom padrão
    }
  }
}
