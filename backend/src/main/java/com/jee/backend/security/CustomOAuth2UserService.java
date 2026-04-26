package com.jee.backend.security;

import com.jee.backend.entity.AuthProvider;
import com.jee.backend.entity.User;
import com.jee.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository userRepository;

    @Override
    @Transactional
    public OAuth2User loadUser(OAuth2UserRequest request) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(request);

        String registrationId = request.getClientRegistration().getRegistrationId();
        AuthProvider provider = AuthProvider.valueOf(registrationId.toUpperCase());

        String email = oAuth2User.getAttribute("email");
        if (email == null || email.isBlank()) {
            throw new OAuth2AuthenticationException(
                    new OAuth2Error("email_not_found"),
                    "Email not returned by " + registrationId + ". Make your email public and try again."
            );
        }

        String name = extractName(registrationId, oAuth2User);
        String providerId = oAuth2User.getName();

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

        return oAuth2User;
    }

    private String extractName(String registrationId, OAuth2User user) {
        if ("github".equals(registrationId)) {
            String name = user.getAttribute("name");
            return (name != null && !name.isBlank()) ? name : user.getAttribute("login");
        }
        return user.getAttribute("name");
    }
}
