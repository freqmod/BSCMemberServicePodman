# Learn about building .NET container images:
# https://github.com/dotnet/dotnet-docker/blob/main/samples/README.md
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG TARGETARCH
WORKDIR /source

# copy csproj and restore as distinct layers
COPY MemberService .
RUN dotnet restore -a $TARGETARCH

# copy and publish app and libraries
RUN mkdir /app
RUN dotnet publish -a $TARGETARCH -c Debug --no-restore -o /app
#RUN cp -r /source/src/MemberService/bin/Release/net8.0/linux-arm64/* /app
#RUN cp -r /source/src/MemberService/wwwroot /app

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
EXPOSE 8080
COPY --from=build /source /source
WORKDIR /app
COPY --from=build /app .
USER $APP_UID
ENTRYPOINT ["/app/MemberService"]
#ENTRYPOINT ["/bin/bash"]
