FROM scratch
LABEL org.opencontainers.image.authors="b.dukai@tudelft.nl"
LABEL maintainer.email="b.dukai@tudelft.nl" maintainer.name="Balázs Dukai"
LABEL description="Tool for reconstructing building models in Level of Detail 1.3"

COPY --from=geoflow3d/geoflow-bundle-builder:latest /export/ /
COPY flowcharts/gfc-lod13/runner.json flowcharts/gfc-lod13/reconstruct_one.json /usr/local/geoflow-flowcharts/gfc-lod13

ENTRYPOINT ["/usr/local/bin/geof", "/usr/local/geoflow-flowcharts/gfc-lod13/runner.json"]
CMD ["--help"]