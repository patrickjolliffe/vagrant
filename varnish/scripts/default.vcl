vcl 4.0;
import bodyaccess;
import std;

backend default {
    .host = "127.0.0.1";
    .port = "1110";
}

sub vcl_recv {
    unset req.http.X-Body-Len;
   // No Cache
   if (std.port(server.ip) == 4110) {
      return (pass);
   }
   // Cache GETs
   elsif (std.port(server.ip) == 4120) {
      return (hash);
   }
   // Cache POSTs
   elsif (std.port(server.ip) == 4130) {
      if (req.method == "POST") {
         std.cache_req_body(500KB);
         set req.http.X-Body-Len = bodyaccess.len_req_body();
         if (req.http.X-Body-Len == "-1") {
            return(synth(400, "The request body size exceeds the limit"));
         }
         return (hash);
      }
   }
}

sub vcl_hash {
   if (req.http.X-Body-Len) {
      bodyaccess.hash_req_body();
   }
   else {
      hash_data("");
   }
}

sub vcl_backend_fetch {
   if (bereq.http.X-Body-Len) {
      set bereq.method = "POST";
   }
}

sub vcl_deliver {
}