FROM google/cloud-sdk

COPY build_and_push.sh /build_and_push.sh

CMD ["/bin/bash", "/build_and_push.sh"]
