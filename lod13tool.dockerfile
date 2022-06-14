FROM scratch
ARG VERSION
LABEL org.opencontainers.image.authors="Balázs Dukai <balazs.dukai@3dgi.nl>"
LABEL org.opencontainers.image.vendor="3DGI"
LABEL org.opencontainers.image.title="lod13tool"
LABEL org.opencontainers.image.description="Tool for reconstructing building models in Level of Detail 1.3"
LABEL org.opencontainers.image.version=$VERSION

COPY --from=geoflow3d/geoflow-bundle-builder:latest /export/ /
COPY flowcharts/gfc-lod13/runner.json flowcharts/gfc-lod13/reconstruct_one.json /usr/local/geoflow-flowcharts/gfc-lod13/

ENTRYPOINT ["/usr/local/bin/geof", "run", "/usr/local/geoflow-flowcharts/gfc-lod13/runner.json"]
CMD ["--help"]