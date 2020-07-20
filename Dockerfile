FROM google/cloud-sdk

COPY build_and_push.sh /build_and_push.sh

RUN apk update && apk add --no-cache jq

CMD ["/bin/bash", "/build_and_push.sh"]
