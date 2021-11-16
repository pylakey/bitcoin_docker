FROM debian:bullseye-slim

RUN apt-get update -y \
  && apt-get install -y  \
    gnupg  \
    wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG BITCOIN_VERSION="22.0"
ARG TARGETARCH="x86_64"
ARG GPG_FINGERPRINT="01EA5486DE18A882D4C2684590C8019E36C2E964"
ARG KEYS="71A3B16735405025D447E8F274810B012346C9A6 01EA5486DE18A882D4C2684590C8019E36C2E964 0CCBAAFD76A2ECE2CCD3141DE2FFD5B1D88CA97D 152812300785C96444D3334D17565732E08E5E41 0AD83877C1F0CD1EE9BD660AD7CC770B81FD22A8 590B7292695AFFA5B672CBB2E13FC145CD3F4304 28F5900B1BB5D1A4B6B6D1A9ED357015286A333D CFB16E21C950F67FA95E558F2EEB9F5CC09526C1 6E01EEC9656903B0542B8F1003DB6322267C373B D1DBF2C4B96F2DEBF4C16654410108112E7EA81F 9D3CC86A72F8494342EA5FD10A41BDC3F4FAFF1C 74E2DEF5D77260B98BC19438099BAD163C70FBFA 637DB1E23370F84AFF88CCE03152347D07DA627C 82921A4B88FD454B7EB8CE3C796C4109063D4EAF"

# Downloading all stuff
RUN wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS
RUN wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc
RUN wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-${TARGETARCH}-linux-gnu.tar.gz

# Verifying
RUN #gpg --batch --keyserver keyserver.ubuntu.com --recv-keys ${KEYS}
RUN #gpg --keyserver keyserver.ubuntu.com --search-keys ${GPG_FINGERPRINT}
RUN #gpg --verify SHA256SUMS.asc SHA256SUMS
RUN sha256sum -c --ignore-missing < SHA256SUMS

# Extract and install
RUN tar -xzf bitcoin-${BITCOIN_VERSION}-${TARGETARCH}-linux-gnu.tar.gz
# Do not install bitcoin-qt
RUN rm bitcoin-${BITCOIN_VERSION}/bin/bitcoin-qt
RUN install -m 0755 -o root -g root -t /usr/local/bin bitcoin-${BITCOIN_VERSION}/bin/*

# Cleanups
RUN rm *.tar.gz \
    && rm SHA256SUMS \
    && rm SHA256SUMS.asc

ENTRYPOINT ["bitcoind"]