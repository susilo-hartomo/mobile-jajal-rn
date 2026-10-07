package com.zeniusapp.network;

import com.zeniusapp.widget.fcy.network.connection.Endpoint;
import com.zeniusapp.widget.fcy.network.connection.Environment;
import com.zeniusapp.widget.fcy.network.endpoint.FcyRateEndpoint;
import com.zeniusapp.widget.fcy.network.endpoint.PokemonEndpoint;
import com.zeniusapp.widget.fcy.network.utils.CurrencyFormatter;
import org.junit.Assert;
import org.junit.Test;

public class NetworkUnitTest {

    @Test
    public void testEnvironmentReading() {
        String url = Environment.getApiURL();
        Assert.assertNotNull(url);
        System.out.println("✓ Environment apiURL: " + url);
    }

    @Test
    public void testCurrencyFormatter() {
        Assert.assertEquals("Rp 186,87", CurrencyFormatter.format("186.8750000"));
        Assert.assertEquals("Rp 16.078", CurrencyFormatter.format("16078.0000000"));
        Assert.assertEquals("Rp 17.685,14", CurrencyFormatter.format("17685.1400000"));
        Assert.assertEquals("Rp 131,2", CurrencyFormatter.format("131.2000000"));
        Assert.assertEquals("-", CurrencyFormatter.format(""));
        Assert.assertEquals("-", CurrencyFormatter.format(null));
        System.out.println("✓ CurrencyFormatter Java Test Passed");
    }

    @Test
    public void testEndpointsCreation() {
        Endpoint fcyEndpoint = FcyRateEndpoint.foreignExchangeRates();
        Assert.assertEquals("/jenius-widget/v1/foreign-exchanges/rates", fcyEndpoint.getPath());

        Endpoint pokemonEndpoint = PokemonEndpoint.pokemonDetail("pikachu");
        Assert.assertNotNull(pokemonEndpoint.getBody());
        System.out.println("✓ Endpoints Creation Java Test Passed");
    }
}
