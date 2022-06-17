FROM scratch
ARG VERSION
LABEL org.opencontainers.image.authors="Balázs Dukai <balazs.dukai@3dgi.nl>"
LABEL org.opencontainers.image.vendor="3DGI"
LABEL org.opencontainers.image.title="lod22-reconstruct"
LABEL org.opencontainers.image.description="Tool for reconstructing building models"
LABEL org.opencontainers.image.version=$VERSION

COPY --from=geoflow3d/geoflow-bundle-builder:latest /export/ /
COPY flowcharts/gfc-brecon/single/reconstruct.json /usr/local/geoflow-flowcharts/gfc-brecon/

ENTRYPOINT ["/usr/local/bin/geof", "/usr/local/geoflow-flowcharts/gfc-brecon/reconstruct.json"]
CMD ["--help"]