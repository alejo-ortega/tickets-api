package xyz.alejo_ortega.tickets_api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Baseline security configuration.
 *
 * <p>Permits the actuator health endpoint so container/orchestrator probes can
 * reach it without credentials, while keeping every other endpoint
 * authenticated. Extend this as the real authentication scheme (JWT) is built
 * out.
 */
@Configuration
public class SecurityConfig {

	@Bean
	public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
		http
			.authorizeHttpRequests(auth -> auth
				.requestMatchers("/actuator/health", "/actuator/health/**").permitAll()
				.anyRequest().authenticated())
			.csrf(csrf -> csrf.disable())
			.httpBasic(Customizer.withDefaults());
		return http.build();
	}
}
