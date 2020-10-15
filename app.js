const http = require('http');
const fs = require("fs");
const crypto = require("crypto");

const hostname = '127.0.0.1';
const port = 3000;
const build_file = 'global_build_number.txt';
const version_file = 'version_number.txt';
var hash = crypto.randomBytes(20).toString('hex');
var oldHash = crypto.randomBytes(20).toString('hex');
var checkHash = crypto.randomBytes(20).toString('hex');

const increment_global_build_number = () => {
    try {
        let data = fs.readFileSync(build_file, 'utf8');

        let incremented = Number(data) + 1;

        fs.writeFileSync(build_file, incremented);

        console.log(`Build number is now: ${incremented}`);

        return {
            code: 200,
            value: incremented
        };
    } catch(e) {
        console.log('R/W error build_number:', e.stack);

        return {
            code: 500,
            value: -1
        };
    }
}

const is_bigger = (new_version_number, old_version_number) => {
    const acceptable_prefix = ['a','b']

    let old_pre;
    let new_pre;

    let old_n = old_version_number.split('.').map((element) => {
        if (isNaN(element)) {
            old_pre = element.slice(0,1);
            return parseInt(element.slice(1));
        } else return parseInt(element);
    });

    let new_n = new_version_number.split('.').map((element) => {
        if (isNaN(element)) {
            new_pre = element.slice(0,1);
            return parseInt(element.slice(1));
        } else return parseInt(element);
    });

    if (acceptable_prefix.includes(old_pre)) {
        if (old_pre === new_pre) {}
        else if (old_pre === 'a' && new_pre === 'b' && new_n[0] === 1 && new_n[1] === 0 && new_n[2] === 0) return true;
        else if (old_pre === 'b' && !new_pre && new_n[0] === 1 && new_n[1] === 0 && new_n[2] === 0) return true;
        else return false;
    }

    // Check that if first element is incremented the rest of the elements are zero
    if (new_n[0] ===  old_n[0] + 1 && new_n[1] === 0 && new_n[2] === 0) {
        return true;
    }
    // Check that if second element is incremented the last element is zero 
    else if (new_n[0] ===  old_n[0] && new_n[1] === old_n[1] + 1 && new_n[2] === 0) {
        return true;
    }
    // Check that if none of the two first elements are incremented the third is
    else if (new_n[0] ===  old_n[0] && new_n[1] === old_n[1] && new_n[2] === old_n[2] + 1) {
        return true;
    } 
    // Else fail
    else return false;
}

const check_version_number = (new_version_number) => {
    try {
        let old_version_number = fs.readFileSync(version_file, 'utf8');

        if (is_bigger(new_version_number, old_version_number)) {
            console.log(`New version number is valid: ${new_version_number}`);

            checkHash = crypto.createHash('sha256').update(hash + new_version_number).digest('hex')
            oldHash = hash;
            hash = crypto.randomBytes(20).toString('hex');

            return {
                code: 200,
                value: new_version_number,
                key: checkHash
            }
        } else {
            console.log(`New version number is not valid: ${new_version_number}, is still ${old_version_number}`);

            return {
                code: 300,
                value: old_version_number,
                key: -1
            }
        }
    } catch (e) {
        console.log('R/W error check_version_number:', e.stack);

        return {
            code: 500,
            value: -1,
            key: -1
        };
    }
}

const increase_version_number = (new_version_number, key) => {
    try {
        let old_version_number = fs.readFileSync(version_file, 'utf8');

        if (is_bigger(new_version_number, old_version_number) && key == checkHash && crypto.createHash('sha256').update(oldHash + new_version_number).digest('hex') == checkHash) {
            checkHash = crypto.randomBytes(20).toString('hex');
            fs.writeFileSync(version_file, new_version_number);

            console.log(`New version number: ${new_version_number}`);

            return {
                code: 200,
                value: new_version_number
            }
        } else {
            console.log(`Failed to update version number to ${new_version_number}, is still ${old_version_number}`);

            return {
                code: 300,
                value: old_version_number
            }
        }
    } catch (e) {
        console.log('R/W error increase_version_number:', e.stack);

        return {
            code: 500,
            value: -1
        };
    }
}

const server = http.createServer((req, res) => {
    if (req.method == 'GET') {
        let build_increment = increment_global_build_number();

        res.statusCode = build_increment.code;

        res.setHeader('Content-Type', 'text/plain');

        res.end(`{ "build": "${build_increment.value}" }`);

    } else if (req.method == 'POST') {
        let body = '';

        req.on('data', chunk => {
            body += chunk.toString();
        });
        req.on('end', () => {
            let json;
            try {
                json = JSON.parse(body).version_number
            } catch (e) {
                console.log("Failed to parse the json")
            }
            let new_version = check_version_number(json)

            res.statusCode = new_version.code;

            res.setHeader('Content-Type', 'text/plain');

            res.end(`{ "version": "${new_version.value}",
                       "key": "${new_version.key}" }`);
        });
    } else if (req.method == 'PUT') {
        let body = '';

        req.on('data', chunk => {
            body += chunk.toString();
        });
        req.on('end', () => {
            let json;
            try {
                json = JSON.parse(body)
            } catch (e) {
                console.log("Failed to parse the json")
            }
            let new_version = increase_version_number(json.version_number, json.key)

            res.statusCode = new_version.code;

            res.setHeader('Content-Type', 'text/plain');

            res.end(`{ "version": "${new_version.value}" }`);
        });
    }
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
