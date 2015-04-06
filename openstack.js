function getKeystoneToken(auth_url, username, password, tenant_name, callback, error_callback) {
    var url = auth_url + "/tokens";
    var data = {"auth":{"passwordCredentials":{"username": username, "password": password}, "tenantName": tenant_name}};
    getDataJson(url, "POST", data, null, callback, error_callback);
}

function getNovaServers(nova_url, token_id, callback, error_callback) {
    var url = nova_url + "/servers/detail";
    getDataJson(url, "GET", null, token_id, callback, error_callback);
}

function getDataJson(url, verb, data, token_id, callback, error_callback) {
    var data_str = data ? JSON.stringify(data) : "";

    console.log(url);
    console.log(data_str);

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if(xhr.status >= 200 && xhr.status < 400) {
                callback(JSON.parse(xhr.responseText));
            } else {
                error_callback(xhr.status, xhr.statusText, xhr.responseText);
            }
        }
    }
    xhr.open(verb, url);
    xhr.setRequestHeader('content-type', 'application/json');
    if(token_id) {
        xhr.setRequestHeader('X-Auth-Token', token_id);
    }
    xhr.send(data_str);
}
