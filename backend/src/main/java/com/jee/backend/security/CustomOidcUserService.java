package com.jee.backend.security;

import com.jee.backend.entity.AuthProvider;
import com.jee.backend.entity.User;
import com.jee.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserRequest;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserService;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CustomOidcUserService extends OidcUserService {

    private final UserRepository userRepository;

    @Override
    @Transactional
    public OidcUser loadUser(OidcUserRequest request) throws OAuth2AuthenticationException {
        OidcUser oidcUser = super.loadUser(request);

        String registrationId = request.getClientRegistration().getRegistrationId();
        AuthProvider provider = AuthProvider.valueOf(registrationId.toUpperCase());

        String email = oidcUser.getEmail();
        if (email == null || email.isBlank()) {
            throw new OAuth2AuthenticationException(
                    new OAuth2Error("email_not_found"),
                    "Email not returned by " + registrationId
            );
        }

        String name = oidcUser.getFullName() != null ? oidcUser.getFullName() : email;
        String providerId = oidcUser.getName();

        userRepository.findByEmail(email).ifPresentOrElse(
                existing -> {
                    if (existing.getProviderId() == null) {
                        existing.linkProvider(provider, providerId);
                    }
                },
                () -> userRepository.save(
                        User.builder()
                                .name(name)
                                .email(email)
                                .provider(provider)
                                .providerId(providerId)
                                .build()
                )
        );

        return oidcUser;
    }
}
